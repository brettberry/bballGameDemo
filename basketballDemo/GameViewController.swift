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
    
    var gameScene: GameScene!
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
        
        let skView = view as? SKView
        gameScene = GameScene(size: view.bounds.size, gameDelegate: self)
        gameScene.setupGameScene()
        gameScene.physicsWorld.contactDelegate = self
        gameScene.delegate = self
        skView?.presentScene(gameScene)
        configurePanGesture()
    }
    
    private func configurePanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
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
            
            let currentBall = gameScene.childNodeWithName("activeBall-\(currentBallindex)")
            currentBall?.physicsBody?.applyImpulse(impulse)
            currentBall?.physicsBody?.affectedByGravity = true

            let shadowNode = gameScene.childNodeWithName("shadow")
            shadowNode?.removeFromParent()
            
            let shrinkBall = SKAction.scaleBy(0.75, duration: 1.0)
            currentBall?.runAction(shrinkBall)
            
            let respawnDelay = SKAction.waitForDuration(1.0)
            let respawn = SKAction.runBlock() {
                self.currentBallindex += 1
                self.gameScene.createBall(self.currentBallindex)
            }

            let reload = SKAction.sequence([respawnDelay, respawn])
            currentBall?.runAction(reload)
            didRegisterBasket = false
        }
    }
}

extension GameViewController: TimerDelegate {

    func timerDidComplete() {
        gameScene.timeLabel.text = "0.00"
        let skView = view as? SKView
        let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.0)
        let gameOver = GameOverScene(size: view.frame.size, score: gameScene.score, gameViewController: self)
        skView?.presentScene(gameOver, transition: reveal)
    }
    
    func timerDidUpdate(withCurrentTime time: NSTimeInterval) {
        if let countdownString = formatter.stringFromNumber(time) {
            gameScene.timeLabel.text = countdownString
        }
    }
}

extension GameViewController: SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let secondNode = contact.bodyB.node
        
        if (contact.bodyA.categoryBitMask == PhysicsType.ball && contact.bodyB.categoryBitMask == PhysicsType.hoop) ||
           (contact.bodyA.categoryBitMask == PhysicsType.hoop && contact.bodyB.categoryBitMask == PhysicsType.ball) {
            if secondNode?.physicsBody?.velocity.dy < 0 && !didRegisterBasket {
                gameScene.score += 1
                gameScene.scoreLabel.text = "\(gameScene.score)"
                didRegisterBasket = true
            }
        }
    }
}

extension GameViewController: SKSceneDelegate {

    func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
        
        let ballNode = scene.childNodeWithName("activeBall-\(currentBallindex)")
        let previousBallNode = scene.childNodeWithName("activeBall-\(currentBallindex - 1)")
        
        if ballNode?.position.y >= gameScene.hoopRect.origin.y - 100 {
            ballNode?.physicsBody?.collisionBitMask = PhysicsType.rim
            gameScene.hoop.zPosition = 4
            gameScene.rimLeft.zPosition = 4
            gameScene.rimRight.zPosition = 4
        } else if previousBallNode?.position.y < gameScene.hoopRect.origin.y - 100 {
            ballNode?.physicsBody?.collisionBitMask = PhysicsType.none
            gameScene.hoop.zPosition = 2
            gameScene.rimLeft.zPosition = 2
            gameScene.rimRight.zPosition = 2
        }
    }
}

extension GameViewController: GameDelegate {

    func gameShouldRestart() {
        
        gameScene.createBall(currentBallindex)
        countdownTimer = Timer(seconds: 20, delegate: self)
        gameScene.score = 0
        clockdidBegin = false
        didRegisterBasket = false
    }
}






