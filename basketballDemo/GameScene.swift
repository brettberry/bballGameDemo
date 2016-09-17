//
//  GameView.swift
//  basketballDemo
//
//  Created by Brett Berry on 6/23/16.
//  Copyright © 2016 Brett Berry. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var ball: SKShapeNode!
    var timeLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var score: Int = 0
    
    var hoopSize: CGSize!
    var hoopRect: CGRect!
    var hoop: SKShapeNode!
    var rimLeft: SKShapeNode!
    var rimRight: SKShapeNode!
    
    var gameScene: SKScene!
    var gameDelegate: GameDelegate!

    init(size: CGSize, gameDelegate: GameDelegate) {
        super.init(size: size)
        self.gameDelegate = gameDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGameScene() {
        if gameScene == nil {
            gameScene = SKScene(size: frame.size)
        }
        let transition = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.0)
        gameScene.backgroundColor = UIColor.whiteColor()
        view?.presentScene(gameScene, transition: transition)
        createHoop()
        createFloor()
        createRim()
        gameDelegate.gameShouldRestart()
        createScoreBoard(score)
    }
    
    func createBall(index: Int) {
        let size = CGSize(width: hoopSize.width, height: hoopSize.width)
        let location = CGPointMake((frame.width - size.width) / 2, 100)
        let rect = CGRectMake(location.x, location.y, size.width, size.height)
        let path = CGPathCreateWithEllipseInRect(rect, nil)
        ball = SKShapeNode(path: path)
        ball.fillColor = UIColor.orangeColor()
        ball.strokeColor = UIColor.orangeColor()
        ball.alpha = 0.0
        ball.zPosition = 3
        ball.name = "activeBall-\(index)"
        
        let ballBody = SKPhysicsBody(circleOfRadius: size.width / 2, center: CGPointMake(location.x + size.width / 2, location.y + size.height / 2))
        ballBody.affectedByGravity = false
        ballBody.categoryBitMask = PhysicsType.ball
        ballBody.collisionBitMask = PhysicsType.rim
        ballBody.contactTestBitMask = PhysicsType.hoop
        ballBody.usesPreciseCollisionDetection = true
        ball.physicsBody = ballBody
        scene?.addChild(ball)

        let fadeIn = SKAction.fadeInWithDuration(0.05)
        ball.runAction(fadeIn)
        
        let shadowSize = CGSize(width: size.width, height: size.height / 3)
        let shadowRect = CGRectMake(location.x, 90, shadowSize.width, shadowSize.height)
        let shadowPath = CGPathCreateWithEllipseInRect(shadowRect, nil)
        let shadow = SKShapeNode(path: shadowPath)
        shadow.name = "shadow"
        shadow.fillColor = UIColor.grayColor()
        shadow.strokeColor = UIColor.clearColor()
        shadow.zPosition = 1
        shadow.alpha = 0.4
        scene?.addChild(shadow)
        
        let highlightSize = CGSize(width: 2 * size.width / 3, height: 2 * size.height / 3)
        let highlightLocation = CGPointMake(location.x + highlightSize.width / 2 - 5, highlightSize.height / 3 + 100)
        let highlightRect = CGRectMake(highlightLocation.x, highlightLocation.y, highlightSize.width, highlightSize.height)
        let highlightPath = CGPathCreateWithEllipseInRect(highlightRect, nil)
        let highlight = SKShapeNode(path: highlightPath)
        highlight.fillColor = UIColor(red: 1, green: 153/255, blue: 51/255, alpha: 1)
        highlight.strokeColor = UIColor.clearColor()
        ball.addChild(highlight)
    }
    
    func createHoop() {
        let width: CGFloat = frame.width * 3/5
        let height: CGFloat = width * 2/3
        let size = CGSize(width: width, height: height)
        let x = (frame.width - size.width) / 2
        let y = (frame.height - size.height) * (3/4)
        let rect = CGRectMake(x, y, size.width, size.height)
        let path = CGPathCreateWithRoundedRect(rect, 20, 20, nil)
        let backboard = SKShapeNode(path: path)
        backboard.strokeColor = UIColor.grayColor()
        backboard.fillColor = UIColor.lightGrayColor()
        backboard.lineWidth = 5
        backboard.zPosition = 2
        scene?.addChild(backboard)
        
        let innerRectSize = CGSize(width: size.width * (2/5), height: size.height * (2/5) + 10)
        let xOffset = x + size.width / 2 - innerRectSize.width / 2
        let yOffset = y + size.height / 2 - innerRectSize.height / 2
        let smallRect = CGRectMake(xOffset, yOffset, innerRectSize.width, innerRectSize.height)
        let smallPath = CGPathCreateWithRect(smallRect, nil)
        let innerRect = SKShapeNode(path: smallPath)
        innerRect.strokeColor = UIColor.grayColor()
        innerRect.lineWidth = 4
        backboard.addChild(innerRect)
        
        hoopSize = CGSize(width: innerRectSize.width, height: 0)
        hoopRect = CGRectMake(xOffset, yOffset, hoopSize.width, hoopSize.height)
        let hoopPath = CGPathCreateWithRoundedRect(hoopRect, 5, 0, nil)
        hoop = SKShapeNode(path: hoopPath)
        hoop.strokeColor = UIColor.darkGrayColor()
        hoop.lineWidth = 7
        hoop.physicsBody?.dynamic = true 
        hoop.zPosition = 2
    
        let hoopBody = SKPhysicsBody(edgeChainFromPath: hoopPath)
        hoopBody.mass = 1.0
        hoopBody.affectedByGravity = false
        hoopBody.categoryBitMask = PhysicsType.hoop
        hoopBody.contactTestBitMask = PhysicsType.ball
        hoopBody.collisionBitMask = PhysicsType.none
        hoopBody.usesPreciseCollisionDetection = true
        hoop.physicsBody = hoopBody
        scene?.addChild(hoop)
    
        let clockSize = CGSize(width: innerRectSize.width, height: innerRectSize.height / 2)
        let clockX = xOffset
        let clockY = y + size.height - innerRectSize.height / 4
        let clockRect = CGRectMake(clockX, clockY, clockSize.width, clockSize.height)
        let clockPath = CGPathCreateWithRoundedRect(clockRect, 5, 5, nil)
        let shotClock = SKShapeNode(path: clockPath)
        shotClock.fillColor = UIColor.grayColor()
        shotClock.strokeColor = UIColor.grayColor()
        backboard.addChild(shotClock)
        
        timeLabel.horizontalAlignmentMode = .Center
        timeLabel.verticalAlignmentMode = .Center
        timeLabel.position = CGPointMake(clockX + clockSize.width / 2, clockY + clockSize.height / 2)
        timeLabel.fontSize = 26
        timeLabel.text = "20.00"
        if timeLabel.parent == nil {
            shotClock.addChild(timeLabel)
        }
    }
    
    func createRim() {
        let rimSize = CGSize(width: 10, height: 0)
        let rimRectLeft = CGRectMake(hoopRect.origin.x - rimSize.width, hoopRect.origin.y, rimSize.width, rimSize.height)
        let rimRectRight = CGRectMake(hoopRect.origin.x + hoopSize.width, hoopRect.origin.y, rimSize.width, rimSize.height)
        let rimPathLeft = CGPathCreateWithRoundedRect(rimRectLeft, 5, 0, nil)
        let rimPathRight = CGPathCreateWithRoundedRect(rimRectRight, 5, 0, nil)
        
        rimLeft = SKShapeNode(path: rimPathLeft)
        rimLeft.strokeColor = UIColor.darkGrayColor()
        rimLeft.lineWidth = 7
        rimLeft.zPosition = 2
        scene?.addChild(rimLeft)
        
        let rimBodyLeft = SKPhysicsBody(edgeChainFromPath: rimPathLeft)
        rimBodyLeft.categoryBitMask = PhysicsType.rim
        rimBodyLeft.contactTestBitMask = PhysicsType.none
        rimBodyLeft.collisionBitMask = PhysicsType.ball
        rimBodyLeft.usesPreciseCollisionDetection = true
        rimLeft.physicsBody = rimBodyLeft

        rimRight = SKShapeNode(path: rimPathRight)
        rimRight.strokeColor = UIColor.darkGrayColor()
        rimRight.lineWidth = 7
        rimRight.zPosition = 2
        scene?.addChild(rimRight)
        
        let rimBodyRight = SKPhysicsBody(edgeChainFromPath: rimPathRight)
        rimBodyRight.categoryBitMask = PhysicsType.rim
        rimBodyRight.contactTestBitMask = PhysicsType.none
        rimBodyRight.collisionBitMask = PhysicsType.ball
        rimBodyRight.usesPreciseCollisionDetection = true
        rimRight.physicsBody = rimBodyRight
    }
    
    private func createFloor() {
        let size = CGSize(width: frame.width, height: frame.height / 4)
        let rect = CGRectMake(0, 0, size.width, size.height)
        let path = CGPathCreateWithRect(rect, nil)
        let floor = SKShapeNode(path: path)
        floor.fillColor = UIColor.lightGrayColor()
        floor.strokeColor = UIColor.lightGrayColor()
        floor.zPosition = 0
        scene?.addChild(floor)
    }
    
    private func createScoreBoard(score: Int) {
        scoreLabel.fontColor = UIColor.grayColor()
        scoreLabel.position = CGPointMake(CGRectGetMidX(frame), frame.height * (3/8) )
        scoreLabel.fontSize = UIFont.systemFontSize() * 6
        scoreLabel.text = "\(score)"
        if scoreLabel.parent == nil {
            scene?.addChild(scoreLabel)
        }
    }
}



