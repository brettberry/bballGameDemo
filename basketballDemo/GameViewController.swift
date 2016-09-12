//
//  ViewController.swift
//  basketballDemo
//
//  Created by Brett Berry on 6/23/16.
//  Copyright © 2016 Brett Berry. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController  {
    
    var gameView: GameView!
    var countdownTimer: Timer!
    var clockBegan = false
    
    var formatter: NSNumberFormatter = {
        var formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        gameView = GameView(frame: view.frame)
        view.addSubview(gameView)
        configurePanGesture()
        countdownTimer = Timer(seconds: 20, delegate: self)
        gameView.scene?.physicsWorld.contactDelegate = self
        gameView.scene?.delegate = self
//        gameView.showsPhysics = true
    }
    
    private func configurePanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        guard let scene = gameView.scene else {
            return
        }
        
        if recognizer.state == .Began {
            if clockBegan == false {
                countdownTimer.start()
                clockBegan = true
            }
        }
        
        if recognizer.state == .Ended {
            let force: CGFloat = 1.0
            let gestureVelocity = recognizer.velocityInView(recognizer.view)
            let impulse = CGVectorMake(gestureVelocity.x * force, gestureVelocity.y * force * -1)
            gameView.ball.physicsBody?.applyImpulse(impulse)
            gameView.ball.physicsBody?.affectedByGravity = true
            
            let shadowNode = scene.childNodeWithName("shadow")
            shadowNode?.removeFromParent()
            gameView.ball.zPosition = 1
            
            let shrinkBall = SKAction.scaleBy(0.75, duration: 1.0)
            gameView.ball.runAction(shrinkBall)
            
            let respawnDelay = SKAction.waitForDuration(0.5)
            let respawn = SKAction.runBlock() {
                self.gameView.createBall()
            }
            let reload = SKAction.sequence([respawnDelay, respawn])
            gameView.ball.runAction(reload)
        }
    }
    
}

extension GameViewController: TimerDelegate {

    func timerDidComplete() {
        gameView.timeLabel.text = "0.00"
    }
    
    func timerDidUpdate(withCurrentTime time: NSTimeInterval) {
        if let countdownString = formatter.stringFromNumber(time) {
            gameView.timeLabel.text = countdownString
        }
    }
}

extension GameViewController: SKPhysicsContactDelegate {

    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstNode = contact.bodyA.node
        let secondNode = contact.bodyB.node
        
        if (contact.bodyA.categoryBitMask == PhysicsType.ball && contact.bodyB.categoryBitMask == PhysicsType.hoop) ||
           (contact.bodyA.categoryBitMask == PhysicsType.hoop && contact.bodyB.categoryBitMask == PhysicsType.ball) {
            
            if firstNode?.position.y > gameView.hoopRect.origin.y || secondNode?.position.y > gameView.hoopRect.origin.y {
                gameView.score += 1
                gameView.scoreLabel.text = "\(gameView.score)"
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
}

extension GameViewController: SKSceneDelegate {

    func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
        
        if gameView.ball.position.y >= gameView.hoopRect.origin.y {
            gameView.ball.physicsBody?.collisionBitMask = PhysicsType.rim
        } else if gameView.ball.position.y < gameView.hoopRect.origin.y {
            gameView.ball.physicsBody?.collisionBitMask = PhysicsType.none
        }
    }
}

