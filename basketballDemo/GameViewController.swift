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
        
        switch recognizer.state {
            
        case .Began:
            let point = recognizer.locationInView(gameView)
            let spritePoint = gameView.convertPoint(point, toScene: scene)
            
        case .Changed:
            let newPoint = recognizer.locationInView(gameView)
            let newSpritePoint = gameView.convertPoint(newPoint, toScene: scene)
            
        case .Ended:
            let force: CGFloat = -1.0
            let gestureVelocity = recognizer.velocityInView(recognizer.view)
            let impulse = CGVectorMake(gestureVelocity.x * force, gestureVelocity.y * force)
            let ballNode = scene.childNodeWithName("ball")
            ballNode?.physicsBody?.applyImpulse(impulse)
            
        default:
            break
        
        }
    
    }
    
    func throwBall() {
        
    
    }
    
    
       
}

