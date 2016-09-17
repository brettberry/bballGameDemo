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
    var clockdidBegin = false
    var didRegisterBasket = false
    var currentBallindex = 0
    
    var formatter: NSNumberFormatter = {
        var formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 2
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameView = GameView(frame: view.frame, gameDelegate: self)
        gameView.setupGameScene()
        gameView.scene?.physicsWorld.contactDelegate = self
        gameView.scene?.delegate = self
        view.addSubview(gameView)
        configurePanGesture()
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
            if clockdidBegin == false {
                countdownTimer.start()
                clockdidBegin = true
            }
        }
        
        if recognizer.state == .Ended {
            let force: CGFloat = 1.0
            let gestureVelocity = recognizer.velocityInView(recognizer.view)
            let (xVelocity, yVelocity) = (gestureVelocity.x / 2, gestureVelocity.y / -2)
            let impulse = CGVectorMake(xVelocity * force, yVelocity * force)
            
            let currentBall = scene.childNodeWithName("activeBall-\(currentBallindex)")
            currentBall?.physicsBody?.applyImpulse(impulse)
            currentBall?.physicsBody?.affectedByGravity = true

            let shadowNode = scene.childNodeWithName("shadow")
            shadowNode?.removeFromParent()
            
            let shrinkBall = SKAction.scaleBy(0.75, duration: 1.0)
            currentBall?.runAction(shrinkBall)
            
            let respawnDelay = SKAction.waitForDuration(1.0)
            let respawn = SKAction.runBlock() {
                self.currentBallindex += 1
                self.gameView.createBall(self.currentBallindex)
            }

            let reload = SKAction.sequence([respawnDelay, respawn])
            currentBall?.runAction(reload)
            didRegisterBasket = false
        }
    }
}

extension GameViewController: TimerDelegate {

    func timerDidComplete() {
        gameView.timeLabel.text = "0.00"
        
        let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.0)
        let gameOver = GameOverScene(size: view.frame.size, score: gameView.score)
        gameView.presentScene(gameOver, transition: reveal)
    }
    
    func timerDidUpdate(withCurrentTime time: NSTimeInterval) {
        if let countdownString = formatter.stringFromNumber(time) {
            gameView.timeLabel.text = countdownString
        }
    }
}

extension GameViewController: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let secondNode = contact.bodyB.node
        
        if (contact.bodyA.categoryBitMask == PhysicsType.ball && contact.bodyB.categoryBitMask == PhysicsType.hoop) ||
           (contact.bodyA.categoryBitMask == PhysicsType.hoop && contact.bodyB.categoryBitMask == PhysicsType.ball) {
            if secondNode?.physicsBody?.velocity.dy < 0 && !didRegisterBasket {
                gameView.score += 1
                gameView.scoreLabel.text = "\(gameView.score)"
                didRegisterBasket = true
            }
        }
    }
}

extension GameViewController: SKSceneDelegate {

    func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
        
        let ballNode = scene.childNodeWithName("activeBall-\(currentBallindex)")
        let previousBallNode = scene.childNodeWithName("activeBall-\(currentBallindex - 1)")
        
        if ballNode?.position.y >= gameView.hoopRect.origin.y - 100 {
            ballNode?.physicsBody?.collisionBitMask = PhysicsType.rim
            gameView.hoop.zPosition = 4
            gameView.rimLeft.zPosition = 4
            gameView.rimRight.zPosition = 4
            gameView.hoop.strokeColor = UIColor.redColor()
        } else if previousBallNode?.position.y < gameView.hoopRect.origin.y - 100 {
            ballNode?.physicsBody?.collisionBitMask = PhysicsType.none
            gameView.hoop.zPosition = 2
            gameView.rimLeft.zPosition = 2
            gameView.rimRight.zPosition = 2
            gameView.hoop.strokeColor = UIColor.blackColor()
        }
    }
}

extension GameViewController: GameDelegate {

    func gameShouldRestart() {
        
//        for node in gameView.scene!.children {
//            node.removeFromParent()
//        }
        
        gameView.createBall(currentBallindex)
        countdownTimer = Timer(seconds: 10, delegate: self)
        gameView.score = 0
        clockdidBegin = false
        didRegisterBasket = false
    }
}






