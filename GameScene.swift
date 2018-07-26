//
//  GameScene.swift
//  FapBird
//
//  Created by Spenser Kline on 7/26/18.
//  Copyright © 2018 Spencer Kline. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Physics {
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
   var ground = SKSpriteNode()
   var ghost = SKSpriteNode()
   var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var points = Int()
    let scoreLabel = SKLabelNode()
    var dead = Bool()
    var resetBtn = SKSpriteNode()
    
    func resetScene(){
        self.removeAllChildren()
        self.removeAllActions()
        dead = false
        gameStarted = false
        points = 0
        createScene()
    }
    
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: 0 , y: self.frame.height / 3 )
        scoreLabel.text = "\(points)"
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.75)
        ground.position = CGPoint(x: 0, y: (0 - self.frame.height / 2) + ground.frame.height / 2 )
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = Physics.ground
        ground.physicsBody?.collisionBitMask = Physics.ghost
        ground.physicsBody?.contactTestBitMask = Physics.ghost
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        
        ground.zPosition = 3
        
        self.addChild(ground)
        
        //adding ghost
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: 0 - ghost.frame.width ,y: 0 )
        
        
        ghost.physicsBody = SKPhysicsBody(circleOfRadius: ghost.frame.height / 2)
        ghost.physicsBody?.categoryBitMask = Physics.ghost
        ghost.physicsBody?.collisionBitMask = Physics.ground | Physics.wall
        ghost.physicsBody?.contactTestBitMask = Physics.ground | Physics.wall | Physics.score
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.isDynamic = true
        
        ghost.zPosition = 2
        
        self.addChild(ghost)
        
        
    }
    
    
    override func didMove(to view: SKView) {
      //adding ground to frame
       createScene()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == Physics.score && secondBody.categoryBitMask == Physics.ghost || firstBody.categoryBitMask == Physics.ghost && secondBody.categoryBitMask == Physics.score
        {
            points += 1
            scoreLabel.text = "\(points)"
        }
    
        if firstBody.categoryBitMask == Physics.ghost && secondBody.categoryBitMask == Physics.wall || firstBody.categoryBitMask == Physics.wall && secondBody.categoryBitMask == Physics.ghost || firstBody.categoryBitMask == Physics.ground && secondBody.categoryBitMask == Physics.ghost || firstBody.categoryBitMask == Physics.ghost && secondBody.categoryBitMask == Physics.ground {
            dead = true
            createBtn()
        }
        
    }
    
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1,height: 200)
        scoreNode.position = CGPoint(x: self.frame.width,y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = Physics.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = Physics.ghost
        scoreNode.color = SKColor.blue
        
        wallPair = SKNode()
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width, y: 500)
        btmWall.position = CGPoint(x: self.frame.width, y: -500)
        
        topWall.zRotation = CGFloat(Double.pi)
        
        topWall.setScale(0.8)
        btmWall.setScale(0.8)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = Physics.wall
        topWall.physicsBody?.collisionBitMask = Physics.ghost
        topWall.physicsBody?.contactTestBitMask = Physics.ghost
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity  = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = Physics.wall
        btmWall.physicsBody?.collisionBitMask = Physics.ghost
        btmWall.physicsBody?.contactTestBitMask = Physics.ghost
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity  = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)

        var randomPosition = CGFloat.random(min: -10, max: 10)
        wallPair.position.y += randomPosition
        wallPair.addChild(scoreNode)
        
        wallPair.zPosition = 1
        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
    }
    
    func createBtn(){
        resetBtn = SKSpriteNode(color: SKColor.blue, size: CGSize(width: 200, height: 200))
        resetBtn.position = CGPoint(x: 0, y: 0)
        resetBtn.zPosition = 6
        self.addChild(resetBtn)
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false{
            gameStarted = true

            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run {
                self.createWalls()
            }
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([spawn,delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CFloat( (self.frame.width + wallPair.frame.width) * 3 )
            let movePipes = SKAction.moveBy( x: CGFloat(-distance), y: 0, duration: TimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence( [movePipes , removePipes])
            
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
        }
        else{
            if dead == true{
               
            }else{
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            }
        }
        
        
        
        for touch in touches{
            let location = touch.location(in: self)
            
            if dead == true{
                if resetBtn.contains(location){
                    resetScene()
                }
            }
        }
       
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
