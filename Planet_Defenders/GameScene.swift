//
//  GameScene.swift
//  Planet_Defenders
//
//  Created by Farzaad Goiporia on 2020-06-17.
//  Copyright © 2020 Farzaad Goiporia. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
     let laserCat:UInt32 = 0x1 << 0
     let enemyCat:UInt32 = 0x1 << 1
     let spaceship = SKSpriteNode(imageNamed: "spaceship")
    
     let laser1 = SKSpriteNode(imageNamed: "beam")
     let enemy1 =  SKSpriteNode(imageNamed: "alien")
     var lastUpdateTime: TimeInterval = 0
     var dt: TimeInterval = 0
     let spaceshipMovePointsPerSec: CGFloat = 480.0
     var velocity = CGPoint.zero
     let playableRect: CGRect
     var lastTouchLocation: CGPoint?
     var ground = SKSpriteNode()
     let jumpSound: SKAction = SKAction.playSoundFileNamed(
       "jumpSound.wav", waitForCompletion: false)
     let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
       "loselifeSound.wav", waitForCompletion: false)
     var invincible = false
     var laser_time = 10

     var lives = 7
     var points = 0
     var gameOver = false
     let cameraNode = SKCameraNode()
     let cameraMovePointsPerSec: CGFloat = 200.0

     let livesLabel = SKLabelNode(fontNamed: "Chalkduster")

       
     override init(size: CGSize) {
       let maxAspectRatio:CGFloat = 16.0/9.0
       let playableHeight = size.width / maxAspectRatio
       let playableMargin = (size.height-playableHeight)/2.0
       playableRect = CGRect(x: 0, y: playableMargin,
                             width: size.width,
                             height: playableHeight)
        
        
        
       super.init(size: size)
     }

     required init(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     }
     
     var cameraRect : CGRect {
       let x = cameraNode.position.x - size.width/2
           + (size.width - playableRect.width)/2
       let y = cameraNode.position.y - size.height/2
           + (size.height - playableRect.height)/2
       return CGRect(
         x: x,
         y: y,
         width: playableRect.width,
         height: playableRect.height)
     }
     func debugDrawPlayableArea() {
       let shape = SKShapeNode()
       let path = CGMutablePath()
       path.addRect(playableRect)
       shape.path = path
       shape.strokeColor = SKColor.red
       shape.lineWidth = 4.0
       addChild(shape)
     }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
            
        }
        if(firstBody.categoryBitMask & laserCat) != 0 && (secondBody.categoryBitMask & enemyCat) != 0{
            laswerDidCollideWithAlien(laser: firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
    }
    func laswerDidCollideWithAlien(laser: SKSpriteNode, enemy: SKSpriteNode){
        points += 1
    }
       
       
     func spawnEnemy() {
        let enemy = enemy1.copy() as! SKSpriteNode
       enemy.position = CGPoint(
        x: CGFloat.random(min: cameraRect.maxX-100, max: cameraRect.maxX),
        y: CGFloat.random(min: cameraRect.minY + 100, max: cameraRect.maxY))
       enemy.zPosition = 50
       enemy.zRotation = -π/2
       enemy.name = "Enemy"
       enemy.setScale(5)
       enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
       enemy.physicsBody!.affectedByGravity = false
        
       enemy.physicsBody?.categoryBitMask = enemyCat
       enemy.physicsBody?.contactTestBitMask = laserCat
        
       addChild(enemy)
       
       let actionMove =
       SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 4.0)
       let actionRemove = SKAction.removeFromParent()
       enemy.run(SKAction.sequence([actionMove, actionRemove]))
     }
       func move(sprite: SKSpriteNode, velocity: CGPoint) {
         let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                    y: velocity.y * CGFloat(dt))
         sprite.position += amountToMove
       }
     override func didMove(to view: SKView) {

        self.physicsWorld.contactDelegate = self
        for i in 0...3{
            let ground = SKSpriteNode(imageNamed: "background")
            ground.name = "Ground"
            ground.size = CGSize(width:(self.scene?.size.width)!,height:(self.scene?.size.height)!)
            ground.anchorPoint = CGPoint(x:0,y:-0.5)
            //ground.setScale(2.5)
            ground.position = CGPoint(x:CGFloat(i)*ground.size.width,y:-(self.frame.size.height/2))
            self.addChild(ground)
        }
       
       
       spaceship.position = CGPoint(x: 400, y: 200)
       spaceship.zPosition = 100
       spaceship.setScale(0.5)
       addChild(spaceship)
    
       
       run(SKAction.repeatForever(
         SKAction.sequence([SKAction.run() { [weak self] in
                         self?.spawnEnemy()
                       },
                       SKAction.wait(forDuration: 2.0)])))
       run(SKAction.repeatForever(
       SKAction.sequence([SKAction.run() { [weak self] in
                       self?.spawnSun_00000()
                     },
                     SKAction.wait(forDuration: 2.0)])))

     
       
       // debugDrawPlayableArea()
       
       addChild(cameraNode)
       camera = cameraNode
       cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
       
       livesLabel.text = "Lives: X"
       livesLabel.fontColor = SKColor.white
       livesLabel.fontSize = 100
       livesLabel.zPosition = 150
       livesLabel.horizontalAlignmentMode = .left
       livesLabel.verticalAlignmentMode = .bottom
       livesLabel.position = CGPoint(
           x: -playableRect.size.width/2 + CGFloat(20),
           y: -playableRect.size.height/2 + CGFloat(20))
       cameraNode.addChild(livesLabel)
       
     }
    
      func spaceshipHit(enemy: SKSpriteNode) {
         invincible = true
         let blinkTimes = 10.0
         let duration = 3.0
         let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
           let slice = duration / blinkTimes
           let remainder = Double(elapsedTime).truncatingRemainder(
             dividingBy: slice)
           node.isHidden = remainder > slice / 2
         }
         let setHidden = SKAction.run() { [weak self] in
           self?.spaceship.isHidden = false
           self?.invincible = false
         }
         spaceship.run(SKAction.sequence([blinkAction, setHidden]))
         
         run(enemyCollisionSound)
         
       
         lives -= 1
       
       }
    func laserHit(laser: SKSpriteNode) {
        laser.removeFromParent()
      points += 1
    
    }
    
    
       
       func spaceshipCollect(Sun_00000: SKSpriteNode) {
           Sun_00000.removeFromParent()
         run(enemyCollisionSound)
           points += 1
       
       }
       
       
       func checkCollisions() {

         if invincible {
           return
         }
        
         var hitEnemies: [SKSpriteNode] = []
         enumerateChildNodes(withName: "Enemy") { node, _ in
           let enemy = node as! SKSpriteNode
           if node.frame.insetBy(dx: 20, dy: 20).intersects(
             self.spaceship.frame) {
             hitEnemies.append(enemy)
           }
         }
         for enemy in hitEnemies {
           spaceshipHit(enemy: enemy)
         }
        
        enumerateChildNodes(withName: "Enemy") { node, _ in
          let enemy = node as! SKSpriteNode
          
            if enemy.zRotation >= -π/2 {
                enemy.removeFromParent()
                self.points += 1
            }
        }
        for enemy in hitEnemies {
          spaceshipHit(enemy: enemy)
        }
        
        
           
           var hitSun_00000s: [SKSpriteNode] = []
           enumerateChildNodes(withName: "Sun_00000") { node, _ in
             let Sun_00000 = node as! SKSpriteNode
               
               if node.frame.insetBy(dx: 20, dy: 20).intersects(
                 self.spaceship.frame) {
                 hitSun_00000s.append(Sun_00000)
               }
             }
             for Sun_00000 in hitSun_00000s {
               spaceshipCollect(Sun_00000: Sun_00000)
             }
        
        var hitLaser: [SKSpriteNode] = []
        enumerateChildNodes(withName: "laser") { node, _ in
          let laser = node as! SKSpriteNode

            if laser.frame.intersects(self.enemy1.frame){
                hitLaser.append(laser)
            }
        }
          for laser in hitLaser {
            self.laserHit(laser: laser)
          }
        
        
        
       }
       func spawnSun_00000() {
         // 1
         let Sun_00000 = SKSpriteNode(imageNamed: "Sun_00000")
         Sun_00000.name = "Sun_00000"
         Sun_00000.position = CGPoint(
           x: CGFloat.random(min: cameraRect.minX,
                             max: cameraRect.maxX),
           y: CGFloat.random(min: cameraRect.minY,
                             max: cameraRect.maxY))
         Sun_00000.zPosition = 1
        Sun_00000.setScale(0.3)
         addChild(Sun_00000)
        

        let actionMove =
        SKAction.moveBy(x: -(size.width + Sun_00000.size.width), y: 0, duration: 4.0)
        let actionRemove = SKAction.removeFromParent()
        Sun_00000.run(SKAction.sequence([actionMove, actionRemove]))
        
       }

     func sceneTouched(touchLocation:CGPoint) {
       let actionJump : SKAction
       actionJump = SKAction.moveBy(x: 0, y: 350, duration: 0.7)
       let jumpSequence = SKAction.sequence([actionJump, actionJump.reversed()])
       spaceship.run(jumpSequence)
       
       }
       override func touchesBegan(_ touches: Set<UITouch>,
            with event: UIEvent?) {
          guard let touch = touches.first else {
            return
          }
          let touchLocation = touch.location(in: self)
          sceneTouched(touchLocation: touchLocation)
        }
    func moveGrounds(){
        self.enumerateChildNodes(withName: "Ground", using: ({
            (node,error) in
            node.position.x -= 2
            if(node.position.x < -((self.scene?.size.width)!))
            {
                node.position.x+=(self.scene?.size.width)! * 3
            }
            
        })
        )
    }
      
    func checkBounds(){
        if(spaceship.position.y >= cameraRect.maxY - 100)
        {
            velocity.y = -velocity.y
            scene?.isUserInteractionEnabled = false
            spaceship.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.run {
                self.scene?.isUserInteractionEnabled = true}]))
            
        }
    }
    
    
    func spawnLaser(){
        let laser = laser1.copy() as! SKSpriteNode
        laser.position = spaceship.position
        laser.zPosition = 100
        laser.name = "laser"
        laser.setScale(3)
        laser.zRotation = -π/2
        laser.physicsBody?.collisionBitMask = enemyCat
        laser.physicsBody?.contactTestBitMask = enemyCat
        laser.physicsBody?.categoryBitMask = laserCat
        laser.physicsBody?.usesPreciseCollisionDetection = true
        addChild(laser)
        
        
        laser.physicsBody?.collisionBitMask = enemyCat
        laser.physicsBody?.categoryBitMask = laserCat
        
        laser.run(SKAction.move(to: CGPoint(x: cameraRect.maxX+100, y: laser.position.y), duration: 1))
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        
    }
    
    func checkShoot(){
        laser_time -= 1
        if(laser_time <= 0){
            spawnLaser()
            laser_time = 10
        }
    }
     override func update(_ currentTime: TimeInterval) {
       moveGrounds()
       checkCollisions()
       checkBounds()
       checkShoot()
       
       
       if lastUpdateTime > 0 {
         dt = currentTime - lastUpdateTime
       } else {
         dt = 0
       }
       lastUpdateTime = currentTime
        
     
       
       move(sprite: spaceship, velocity: velocity)
       livesLabel.text = "Lives: \(lives)\t\tPoints\(points)"
     
        
       if lives <= 0 && !gameOver {
         gameOver = true
         print("You lose!")
       
     }
     
       }
     
    
     
    

       
    
}
