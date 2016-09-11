//
//  ViewController.swift
//  basketballDemo
//
//  Created by Brett Berry on 6/23/16.
//  Copyright © 2016 Brett Berry. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SKPhysicsContactDelegate {
    
    var gameView: GameView!

    override func viewDidLoad() {
        super.viewDidLoad()
        gameView = GameView(frame: view.frame)
        view.addSubview(gameView)
    
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(pan)
    }
    
    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        guard let scene = gameView.scene else {
            return
        }
        
        if recognizer.state == .Ended {
            let force: CGFloat = 1.0
            let gestureVelocity = recognizer.velocityInView(recognizer.view)
            let impulse = CGVectorMake(gestureVelocity.x * force, gestureVelocity.y * force * -1)
            let ballNode = scene.childNodeWithName("ball")
            ballNode?.physicsBody?.applyImpulse(impulse)
            ballNode?.physicsBody?.affectedByGravity = true
            
            let shadowNode = scene.childNodeWithName("shadow")
            shadowNode?.removeFromParent()
            
            ballNode?.name = "inactiveBall"
            
            let respawnDelay = SKAction.waitForDuration(1.0)
            let respawn = SKAction.runBlock() {
                self.gameView.createBall()
            }
            
            let reload = SKAction.sequence([respawnDelay, respawn])
            ballNode?.runAction(reload)
        }
    }


}

