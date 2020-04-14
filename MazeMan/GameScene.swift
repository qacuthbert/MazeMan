//
//  GameScene.swift
//  MazeMan
//
//  Created by QC on 4/12/20.
//  Copyright © 2020 Quincey Cuthbert. All rights reserved.
//

import SpriteKit
import GameplayKit


struct PhysicsCategory {
    static let Water: UInt32 = 0x1 << 0
    static let Dino: UInt32 = 0x1 << 1
    static let Caveman: UInt32 = 0x1 << 2
    static let Block: UInt32 = 0x1 << 3
    static let Food: UInt32 = 0x1 << 4
    static let Star: UInt32 = 0x1 << 5
    static let Fireball: UInt32 = 0x1 << 6
    static let FlyingDino: UInt32 = 0x1 << 7
    static let Rock: UInt32 = 0x1 << 8
    static let SpikesDino: UInt32 = 0x1 << 9
}

/*
 enum PhysicsCategory: UInt32 {
 case caveman = 1
 case dino = 2
 case water = 4
 case block = 8
 }
 */

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var swipeGR: UISwipeGestureRecognizer!
    var swipeUp: UISwipeGestureRecognizer!
    var swipeDown: UISwipeGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeRight: UISwipeGestureRecognizer!
    
    var caveman: SKSpriteNode!
    var block: SKSpriteNode!
    var water: SKSpriteNode!
    var food: SKSpriteNode!

    var fire: SKSpriteNode!
    var dino1: SKSpriteNode!
    var dino2: SKSpriteNode!
    var dino3: SKSpriteNode!
    var dino4: SKSpriteNode!
    
    var star: SKSpriteNode!
    var starLabel: SKLabelNode!
    var starString: String!
    var starInt: Int!
    
    var battery: SKSpriteNode!
    var batteryLabel: SKLabelNode!
    var batteryString: String!
    var batteryInt: Int!
    
    var heart: SKSpriteNode!
    var heartLabel: SKLabelNode!
    var heartString: String!
    var heartInt: Int!
    
    var rock: SKSpriteNode!
    var rockLabel: SKLabelNode!
    var rockString: String!
    var rockInt: Int!
    
    var rockThrow: SKSpriteNode!
    var gamePanel: SKSpriteNode!
    var messageLabel: SKLabelNode!
    var gameBackground: SKSpriteNode!
    var fireball: SKSpriteNode!
    
    var messageString: String!
    
    var grid: Grid!
    // var sprites : [[SKSpriteNode]]!
    
    
   // var heartCount = 0
   // var rockCount = 0
   // var batteryCount = 0
   // var starCount = 0
    
    var moveUp: SKAction!
    var moveDown: SKAction!
    var moveLeft: SKAction!
    var moveRight: SKAction!
    
    
    
    
    
    //  private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        
        
        self.physicsWorld.contactDelegate = self
        
        
        

        
        let gameBackground = SKSpriteNode(imageNamed: "bg")
        
        gameBackground.size = CGSize(width: 1024, height: 768)
        gameBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        gameBackground.zPosition = -1
        // self.addChild(gameBackground)
        
        grid = Grid(blockSize: 64.0, rows:12, cols:16)
        // sprites = Array(repeating: Array(repeating: 0, count: 5), count: 5)
        // sprites = Array2D(columns: 16, rows: 12, initialValue: SKSpriteNode())
        
        grid.position = CGPoint (x:frame.midX, y:frame.midY)
        addChild(grid)
        
        
        
        
        
        let cavemanTexture = SKTexture(imageNamed: "caveman")
        caveman = SKSpriteNode(texture: cavemanTexture)
        caveman.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: caveman.size.width, height: caveman.size.height))
        caveman.physicsBody?.isDynamic = true
        caveman.physicsBody?.affectedByGravity = false
        caveman.physicsBody?.categoryBitMask = PhysicsCategory.Caveman
        caveman.physicsBody?.collisionBitMask = PhysicsCategory.Block
        // | PhysicsCategory.Dino | PhysicsCategory.Fireball
        caveman.physicsBody?.contactTestBitMask = PhysicsCategory.Block |
            PhysicsCategory.Dino | PhysicsCategory.Fireball | PhysicsCategory.Food | PhysicsCategory.Star | PhysicsCategory.Water
        caveman.setScale(0.1)
        caveman.position = grid.gridPosition(row: 10, col: 0)
        //  caveman.physicsBody = SKPhysicsBody(rectangleOf: caveman.size)
        // caveman.physicsBody?.categoryBitMask = PhysicsCategory.tutorial
        // caveman.physicsBody?.isDynamic = true
        grid.addChild(caveman)
        // caveman.affectedByGravity = false
        
        
        
        
        /*
         categoryBitMask: the type of the object
         for collisions
         • collisionBitMask: what categories of
         objects this node should collide with
         • contactTestBitMask which contacts we
         want to be notified about.
         */
        
        // newProjectile()
        
        
        
        setUp()
        grid.setUp()
        addGestures()
        
        
        heart = SKSpriteNode(imageNamed: "heart")
        heart.position = CGPoint(x: 160, y: 32)
        heart.size = CGSize(width: 64, height: 64)
        heart.zPosition = 0.75
        self.addChild(heart)
        
        heartLabel.position = CGPoint(x: 160, y: 32)
        heartLabel.fontSize = 30
        heartLabel.fontColor = SKColor.white
        heartLabel.fontName = "Courier-Bold"
        heartLabel.zPosition = 1
        self.addChild(heartLabel)
        
        rock = SKSpriteNode(imageNamed: "rock")
        rock.position = CGPoint(x: 96, y: 32)
        rock.size = CGSize(width: 64, height: 64)
        rock.zPosition = 0.75
        self.addChild(rock)
        
        rockLabel.position = CGPoint(x: 96, y: 32)
        rockLabel.fontSize = 30
        rockLabel.fontColor = SKColor.white
        rockLabel.fontName = "Courier-Bold"
        rockLabel.zPosition = 1
        self.addChild(rockLabel)
        
        battery = SKSpriteNode(imageNamed: "battery")
        battery.position = CGPoint(x: 230, y: 32)
        battery.size = CGSize(width: 100, height: 100)
        battery.zPosition = 0.75
        self.addChild(battery)
        
        batteryLabel.position = CGPoint(x: 224, y: 32)
        batteryLabel.fontSize = 30
        batteryLabel.fontColor = SKColor.white
        batteryLabel.fontName = "Courier-Bold"
        batteryLabel.zPosition = 1
        self.addChild(batteryLabel)
        
        star = SKSpriteNode(imageNamed: "star")
        star.position = CGPoint(x: 32, y: 32)
        star.size = CGSize(width: 64, height: 64)
        star.zPosition = 0.75
        self.addChild(star)
        
        starLabel.position = CGPoint(x: 32, y: 32)
        starLabel.fontSize = 30
        starLabel.fontColor = SKColor.white
        starLabel.fontName = "Courier-Bold"
        starLabel.zPosition = 1
        self.addChild(starLabel)
        
        gamePanel = SKSpriteNode(imageNamed: "game-status-panel")
        gamePanel.position = CGPoint(x: size.width/2, y: size.height-64)
        gamePanel.size = CGSize(width: size.width, height: 128)
        gamePanel.zPosition = 0.5
        self.addChild(gamePanel)
        
        
        /*
         // Get label node from scene and store it for use later
         self.messageLabel = self.childNode(withName: "//helloLabel") as? SKLabelNode
         if let label = self.messageLabel {
         label.fontColor = SKColor.white
         label.alpha = 0.0
         label.run(SKAction.fadeIn(withDuration: 2.0))
         }
         */
       // messageString = " "
        messageLabel = SKLabelNode(text: "MazeMan starts NOW! Good Luck!!")
        messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
        messageLabel.fontSize = 30
        messageLabel.fontColor = SKColor.white
        messageLabel.fontName = "Courier-Bold"
        messageLabel.zPosition = 1

        self.addChild(messageLabel)
        messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
            /*
        self.messageLabel = self.childNode(withName: "messageLabel") as? SKLabelNode
           if let label = self.messageLabel {
           label.fontColor = SKColor.white
           label.alpha = 0.0
           label.run(SKAction.fadeIn(withDuration: 2.0))
           }
        */

        
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        
        
    }
    
    
    func addGestures(){
        
        swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        self.view?.addGestureRecognizer(swipeGR)
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        swipeRight.direction = .right
        self.view?.addGestureRecognizer(swipeRight)
        
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        swipeLeft.direction = .left
        self.view?.addGestureRecognizer(swipeLeft)
        
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = .up
        self.view?.addGestureRecognizer(swipeUp)
        
        
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        swipeDown.direction = .down
        self.view?.addGestureRecognizer(swipeDown)
    }
    
    @objc func swipedUp(){
        moveUp = SKAction.move(by: CGVector(dx: 0, dy: self.frame.height-caveman.frame.height-30), duration: 1.0)
        moveUp.speed = 0.2
        moveUp.timingMode = .easeInEaseOut
        caveman.run(moveUp)
        
        print("swiped up")
    }
    
    @objc func swipedDown(){
        moveDown = SKAction.move(by: CGVector(dx: 0, dy: -self.frame.height+caveman.frame.height+30), duration: 1.0)
        moveDown.speed = 0.2
        moveDown.timingMode = .easeInEaseOut
        caveman.run(moveDown)
        
        print("swiped down")
    }
    
    @objc func swipedLeft(){
        moveLeft = SKAction.move(by: CGVector(dx: -self.frame.width+caveman.frame.width+30, dy: 0), duration: 1.0)
        moveLeft.speed = 0.2
        moveLeft.timingMode = .easeInEaseOut
        caveman.run(moveLeft)
        
        print("swiped left")
    }
    
    @objc func swipedRight(){
    moveRight = SKAction.move(by: CGVector(dx: self.frame.width-caveman.frame.width-30, dy: 0), duration: 1.0)
    moveRight.speed = 0.2
    moveRight.timingMode = .easeInEaseOut
    caveman.run(moveRight)
        
        print("swiped right")
    }
    
    @objc func swiped(){
        
        print("swiped")
        //caveman.physicsBody?.affectedByGravity = false
        
        /*
         if ball.physicsBody?.affectedByGravity == true
         {
         ball.physicsBody?.affectedByGravity = false
         ball.physicsBody?.isDynamic = false
         }
         else{
         ball.physicsBody?.affectedByGravity = true
         ball.physicsBody?.isDynamic = true
         }
         */
        
        
        
    }
    
    func setUp() -> Void {
        
        
      // messageLabel.text = messageString
        //messageLabel.text = "Test!"
       
        
        if let label = self.messageLabel {
            label.fontColor = SKColor.white
            label.alpha = 1.0
            //  label.run(SKAction.fadeIn(withDuration: 2.0), SKAction.fadeOut(withDuration: 6.0))
             self.addChild(label)
            label.run(SKAction.fadeOut(withDuration: 5.0))
            
        }
        
        heartInt = 3
        heartString = "\(String(describing: heartInt))"
        heartLabel = SKLabelNode(text: heartString)
        rockInt = 10
        rockString = "\(String(describing: rockInt))"
        rockLabel = SKLabelNode(text: rockString)
        batteryInt = 100
        batteryString = "\(String(describing: batteryInt))"
        batteryLabel = SKLabelNode(text: batteryString)
        starInt = 0
        starString = "\(String(describing: starInt))"
        starLabel = SKLabelNode(text: starString)
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Water) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Water){
         
         print("Drowned!!!")
            
          /*  messageLabel = SKLabelNode(text: "Oh no! MazeMan drowned!!!")
            
            if let label = self.messageLabel {
                label.fontColor = SKColor.white
                label.alpha = 1.0
                //  label.run(SKAction.fadeIn(withDuration: 2.0), SKAction.fadeOut(withDuration: 6.0))
                label.run(SKAction.fadeOut(withDuration: 5.0))
            }
 */
            
        }
        
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Block) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Block){
         
         print("Ouch!")
            
            messageLabel.removeFromParent()
            messageLabel = SKLabelNode(text: "MazeMan needs to watch where he's going!")
            messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
            messageLabel.fontSize = 30
            messageLabel.fontColor = SKColor.white
            messageLabel.fontName = "Courier-Bold"
            messageLabel.zPosition = 1

            self.addChild(messageLabel)
            messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
            
        }
        
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Star) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Star){
         
         print("Star!")
            grid.removeStar()
            messageLabel.removeFromParent()
            messageLabel = SKLabelNode(text: "Cool! A star!!")
            messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
            messageLabel.fontSize = 30
            messageLabel.fontColor = SKColor.white
            messageLabel.fontName = "Courier-Bold"
            messageLabel.zPosition = 1
            self.addChild(messageLabel)
            messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
              
                starInt = starInt+1
                self.grid.addStar()
            
        }
        
        /*
         Every time player contacts a food, its energy increases by 50
         (half heart) and food disappears (removed from parent). The
         player status panel should be updated accordingly. Food can
         also be eaten by enemy types dino1, dino2 or dino3, (not by
         fire coming from dino4). Another food is added to screen
         immediately after the previous food (if eaten by player). If an
         enemy has eaten the food, then new one will be added after
         10 seconds
         
         */
        
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Food) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Food){
         
         print("Yum!")
            grid.removeFood()
            messageLabel.removeFromParent()
            messageLabel = SKLabelNode(text: "MazeMan loves to eat!")
            messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
            messageLabel.fontSize = 30
            messageLabel.fontColor = SKColor.white
            messageLabel.fontName = "Courier-Bold"
            messageLabel.zPosition = 1
            self.addChild(messageLabel)
            messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
              
                self.grid.addFood()
            
        }
        
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Dino) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Dino){
         
         print("Hungry Dino!")
            grid.removeFood()
            
            messageLabel.removeFromParent()
            messageLabel = SKLabelNode(text: "Dinos love to eat too!")
            messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
            messageLabel.fontSize = 30
            messageLabel.fontColor = SKColor.white
            messageLabel.fontName = "Courier-Bold"
            messageLabel.zPosition = 1
            self.addChild(messageLabel)
            messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
            
            let delayTime = DispatchTime.now() + 10.0
            DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                
                self.grid.addFood()
                
            })
            
        }
        
        
          //   messageLabel = SKLabelNode(text: "MazeMan needs to watch where he's going!")
             
          //  messageLabel.text = messageString
            
             /*
             if let label = self.messageLabel {
                 label.fontColor = SKColor.white
                 label.alpha = 1.0
                 //  label.run(SKAction.fadeIn(withDuration: 2.0), SKAction.fadeOut(withDuration: 6.0))
                  self.addChild(label)
                 label.run(SKAction.fadeOut(withDuration: 5.0))
                 
             }
 */
          
            /*messageLabel = SKLabelNode(text: "MazeMan needs to watch where he's going!")
    
            let rockLabel = self.messageLabel
              //  label.fontColor = SKColor.white
              //  label.alpha = 1.0
                //  label.run(SKAction.fadeIn(withDuration: 2.0), SKAction.fadeOut(withDuration: 6.0))
                 self.addChild(rockLabel!)
            rockLabel!.run(SKAction.fadeOut(withDuration: 5.0))
                
            */
            
           // if let label = self.messageLabel {
               // label.fontColor = SKColor.white
               // label.alpha = 1.0
                //  label.run(SKAction.fadeIn(withDuration: 2.0), SKAction.fadeOut(withDuration: 6.0))
              //  Message().display(message: "MazeMan needs to watch where he's going!")
                
              //  sequence(SKAction.fadeIn(withDuration: 2.0), SKAction.fadeOut(withDuration: 6.0))
         //   }
            
        
         
            /*
         //circle.removeFromParent()
         
         let rem = SKAction.removeFromParent()
         
         //circle.run(rem)
         
         circle.removeAction(forKey: "action1")
         
         let a2 =  SKAction.scale(by: 1.5, duration: 1.0)
         
         circle.run(a2)
         
         gameOver()
         
         //
         
         //circle.physicsBody?.isDynamic = true
         }
         
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Ball && contact.bodyB.categoryBitMask == PhysicsCategory.Ground) || (contact.bodyB.categoryBitMask == PhysicsCategory.Ball && contact.bodyA.categoryBitMask == PhysicsCategory.Ground){
         
         print("Ball contacts ground")
         
         }
         
         
         
         if (contact.bodyA.categoryBitMask == PhysicsCategory.Circle && contact.bodyB.categoryBitMask == PhysicsCategory.Ground) || (contact.bodyB.categoryBitMask == PhysicsCategory.Circle && contact.bodyA.categoryBitMask == PhysicsCategory.Ground){
         
         print("Circle hits ground")
         }
         */
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //  if let label = self.label {
        //      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        //  }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
    func newProjectile () {
        rockThrow = SKSpriteNode(imageNamed: "rock")
        rockThrow.name = "beaker"
        rockThrow.zPosition = 5
        rockThrow.position = caveman.position
        let rockBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
        rockBody.mass = 1.0
        //  rockBody.categoryBitMask = PhysicsType.rockThrow
        //  rockBody.collisionBitMask = PhysicsType.wall | PhysicsType.dino
        rockThrow.physicsBody = rockBody
        addChild(rockThrow)
        
        if let cavemanBody = caveman.physicsBody {
            let  pinRockToCaveman = SKPhysicsJointFixed.joint(withBodyA: cavemanBody, bodyB: rockBody, anchor: CGPoint.zero)
            physicsWorld.add(pinRockToCaveman)
            //  rockReady = true
        }
        
        
        
        
    }
    /*
     class GameScene: SKScene {
     override func didMove(to: SKView) {
     if let grid = Grid(blockSize: 64.0, rows:10, cols:16) {
     grid.position = CGPoint (x:frame.midX, y:frame.midY)
     addChild(grid)
     print(grid)
     
     let gamePiece = SKSpriteNode(imageNamed: "caveman")
     gamePiece.setScale(0.0625)
     gamePiece.position = grid.gridPosition(row: 1, col: 0)
     grid.addChild(gamePiece)
     }
     }
     }
     */
    
}

