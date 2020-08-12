//
//  GameScene.swift
//  MazeMan
//
//  Created by QC on 4/12/20.
//  Copyright © 2020 Quincey Cuthbert. All rights reserved.
//

import SpriteKit
import GameplayKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct Score {
   public static var count = 0
}

struct PhysicsCategory {
    static let None: UInt32 = 0x1 << 0
    static let Dino1: UInt32 = 0x1 << 1
    static let Caveman: UInt32 = 0x1 << 2
    static let Block: UInt32 = 0x1 << 3
    static let Food: UInt32 = 0x1 << 4
    static let Star: UInt32 = 0x1 << 5
    static let Fireball: UInt32 = 0x1 << 6
    static let Dino4: UInt32 = 0x1 << 7
    static let Rock: UInt32 = 0x1 << 8
    static let Dino3: UInt32 = 0x1 << 9
    static let Wall: UInt32 = 0x1 << 10
    static let Water: UInt32 = 0x1 << 11
    static let Dino2: UInt32 = 0x1 << 12
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var dino1Hit: Bool = false
    var dino2Hit: Bool = false
    var dino3Hit: Bool = false
    
    var lastRockTimeInterval: TimeInterval = 0
    var lastEnergyTimeInterval: TimeInterval = 0
    var lastBlockTimeInterval: TimeInterval = 0
    var lastFireTimeInterval: TimeInterval = 0
    var lastGravityTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    
    var tapGR: UITapGestureRecognizer!
    var swipeGR: UISwipeGestureRecognizer!
    var swipeUp: UISwipeGestureRecognizer!
    var swipeDown: UISwipeGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeRight: UISwipeGestureRecognizer!
    
    var caveman: SKSpriteNode!
    
    var star: SKSpriteNode!
    var starLabel: SKLabelNode!
    var starString: String!
    var starInt = 0
    
    var battery: SKSpriteNode!
    var batteryLabel: SKLabelNode!
    var batteryString: String!
    var batteryInt = 0
    
    var heart: SKSpriteNode!
    var heartLabel: SKLabelNode!
    var heartString: String!
    var heartInt = 0
    
    var rock: SKSpriteNode!
    var rockLabel: SKLabelNode!
    var rockString: String!
    var rockInt = 0
    
    var rockThrow: SKSpriteNode!
    var gamePanel: SKSpriteNode!
    var messageLabel: SKLabelNode!
    var gameBackground: SKSpriteNode!
    var fireball: SKSpriteNode!
    
    var messageString: String!
    
    var grid: Grid!
    
    var blockCount = 0
    
    var moveUp: SKAction!
    var moveDown: SKAction!
    var moveLeft: SKAction!
    var moveRight: SKAction!
    
    override func didMove(to view: SKView) {
        
        
        
        let gameBackground = SKSpriteNode(imageNamed: "bg")
        gameBackground.size = CGSize(width: 1024, height: 768)
        gameBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        gameBackground.zPosition = 0
        self.addChild(gameBackground)
        
        grid = Grid(blockSize: 64.0, rows:12, cols:16)
        
        grid.position = CGPoint (x:frame.midX, y:frame.midY)
        addChild(grid)
        
        
        
        messageLabel = SKLabelNode(fontNamed: "Courier-Bold")
        messageLabel.text = " "
        messageLabel.fontSize = 30
        messageLabel.fontColor = SKColor.white
        messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
        messageLabel.zPosition = 1
        
        self.addChild(messageLabel)
        
        star = SKSpriteNode(imageNamed: "star")
        star.position = CGPoint(x: 32, y: 32)
        star.size = CGSize(width: 64, height: 64)
        star.zPosition = 0.75
        self.addChild(star)
        
        
        starString = "\(starInt)"
        starLabel = SKLabelNode(fontNamed: "Courier-Bold")
        starLabel.text = starString
        starLabel.fontSize = 20
        starLabel.fontColor = SKColor.white
        // starLabel.fontName = "Courier-Bold"
        starLabel.position = CGPoint(x: 32, y: 32)
        starLabel.zPosition = 1
        self.addChild(starLabel)
        
        setUp()
        grid.setUp()
        addGestures()
        
        
        heart = SKSpriteNode(imageNamed: "heart")
        heart.position = CGPoint(x: 160, y: 32)
        heart.size = CGSize(width: 64, height: 64)
        heart.zPosition = 0.75
        self.addChild(heart)
        
        heartLabel.position = CGPoint(x: 160, y: 32)
        heartLabel.fontSize = 20
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
        rockLabel.fontSize = 20
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
        batteryLabel.fontSize = 20
        batteryLabel.fontColor = SKColor.white
        batteryLabel.fontName = "Courier-Bold"
        batteryLabel.zPosition = 1
        self.addChild(batteryLabel)
        
        gamePanel = SKSpriteNode(imageNamed: "game-status-panel")
        gamePanel.position = CGPoint(x: size.width/2, y: size.height-64)
        gamePanel.size = CGSize(width: size.width, height: 128)
        gamePanel.zPosition = 0.5
        self.addChild(gamePanel)
        
    }
    
    
    func addCaveman() -> Void {
        
        let cavemanTexture = SKTexture(imageNamed: "caveman")
        caveman = SKSpriteNode(texture: cavemanTexture)
        caveman.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        caveman.physicsBody?.isDynamic = true
        caveman.physicsBody?.affectedByGravity = false
        caveman.physicsBody?.allowsRotation = false
        caveman.physicsBody?.categoryBitMask = PhysicsCategory.Caveman
        caveman.physicsBody?.collisionBitMask = PhysicsCategory.Block
            | PhysicsCategory.Wall | PhysicsCategory.Fireball
        caveman.physicsBody?.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3 | PhysicsCategory.Fireball | PhysicsCategory.Food | PhysicsCategory.Star | PhysicsCategory.Water | PhysicsCategory.Wall
        caveman.size = CGSize(width: 50, height: 50)
        caveman.position = grid.gridPosition(row: 10, col: 0)
        caveman.zPosition = 1
        grid.addChild(caveman)
        
        physicsWorld.contactDelegate = self
    }
    
    
    func addGestures(){
        
        tapGR = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.view?.addGestureRecognizer(tapGR)
        
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
    
    @objc func tapped() {
        // 1 - Choose one of the touches to work with
        // print("tapped!")
        
        let touchLocation = touchPosition.point
        print("touch location is \(touchLocation)")
        
        // 2 - Set up initial location of projectile
        if self.rockReady() {
            decreaseRock()
            self.newProjectile()
          //  rockThrow = self.newProjectile() as? SKSpriteNode
         //   if let projectile = rockThrow {
                rockThrow.position = caveman.position
              //  print("caveman is: \(caveman.position)")
                // 3 - Determine offset of location to projectile
                let offset = touchLocation - rockThrow.position
                
                // 4 - Bail out if you are shooting down or backwards
                //if offset.x < 0 { return }
                
                // 5 - OK to add now - you've double checked position
                addChild(rockThrow)
                
                // 6 - Get the direction of where to shoot
                let direction = offset.normalized()
                
                // 7 - Make it shoot far enough to be guaranteed off screen
                let shootAmount = direction * 2000
                
                // 8 - Add the shoot amount to the current position
                let realDest = shootAmount + rockThrow.position
                
                // 9 - Create the actions
                let actionMove = SKAction.move(to: realDest, duration: 4.0)
  
            rockThrow.run(actionMove)
                
          //  }
        }
        
    }
    
    @objc func swipedUp(){
        caveman.removeAllActions()
        moveUp = SKAction.move(by: CGVector(dx: 0, dy: self.frame.height-caveman.frame.height-30), duration: 1.0)
        moveUp.speed = 0.2
        moveUp.timingMode = .linear
        caveman.run(moveUp)
        
      //  print("swiped up")
    }
    
    @objc func swipedDown(){
        caveman.removeAllActions()
        moveDown = SKAction.move(by: CGVector(dx: 0, dy: -self.frame.height+caveman.frame.height+30), duration: 1.0)
        moveDown.speed = 0.2
        moveDown.timingMode = .linear
        caveman.run(moveDown)
        
     //   print("swiped down")
    }
    
    @objc func swipedLeft(){
        let flipLeft = SKAction.scaleX(to: 1, duration: 0.1)
        
        caveman.removeAllActions()
        moveLeft = SKAction.move(by: CGVector(dx: -self.frame.width+caveman.frame.width+30, dy: 0), duration: 1.0)
        
        moveLeft.speed = 0.2
        moveLeft.timingMode = .linear
        
        caveman.run(flipLeft)
        caveman.run(moveLeft)
        
      //  print("swiped left")
    }
    
    @objc func swipedRight(){
        let flipRight = SKAction.scaleX(to: -1, duration: 0.1)
        
        caveman.removeAllActions()
        moveRight = SKAction.move(by: CGVector(dx: self.frame.width-caveman.frame.width-30, dy: 0), duration: 1.0)
        moveRight.speed = 0.2
        moveRight.timingMode = .linear
        
        caveman.run(flipRight)
        caveman.run(moveRight)
        
      //  print("swiped right")
    }
    
    @objc func swiped(){
        
        print("swiped")
    }
    
    func gravityOn() -> Void {
        let delayTime = DispatchTime.now() + 10.0
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            
            self.caveman.physicsBody?.affectedByGravity = true
            self.gravityOff()
            
        })
        
    }
    
    func gravityOff() -> Void {
        let delayTime = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            
            self.caveman.physicsBody?.affectedByGravity = false
            
        })
    }
    
    func setUp() -> Void {
        addCaveman()
        changeMessageLabel(newText: "MazeMan starts NOW! Good Luck!!")
        
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
        starLabel.text = starString
        
    }
    
    func takesDamage(damageAmount: Int) -> Void {
        
        decreaseEnergy(subtractAmount: damageAmount)
        
    }
    
    func increaseEnergy(addAmount: Int) -> Void {
        let addEnergy = addAmount
        batteryInt = batteryInt + addEnergy
        
        if batteryInt >= 100 {
            if heartInt < 3{
        increaseHeart()
            batteryInt = batteryInt-100
            }
            else{
                batteryInt = 100
            }
        }
        
        batteryString = "\(batteryInt)"
        batteryLabel.text = batteryString
        
    }
    
    func decreaseEnergy(subtractAmount: Int) -> Void {
        let subtractEnergy = subtractAmount
        batteryInt = batteryInt - subtractEnergy
        
        if batteryInt <= 0 {
        decreaseHeart()
            batteryInt = batteryInt+100
        }
        
        batteryString = "\(batteryInt)"
        batteryLabel.text = batteryString
    }
    
    func increaseHeart() -> Void {
        if heartInt < 3 {
        heartInt+=1
        heartString = "\(heartInt)"
        heartLabel.text = heartString
        }
    }
    
    func decreaseHeart() -> Void {
        if heartInt > 0 {
        heartInt-=1
        heartString = "\(heartInt)"
        heartLabel.text = heartString
        }
      
        else {
            gameOver()
        }

    }
    
    func increaseStar() -> Void {
        starInt+=1
        starString = "\(starInt)"
        starLabel.text = starString
    }
    
    func increaseRock() -> Void {
        if rockInt < 20 {
        rockInt+=1
        rockString = "\(rockInt)"
        rockLabel.text = rockString
        }
    }
    
    func decreaseRock() -> Void {
        if rockInt > 0 {
        rockInt-=1
        rockString = "\(rockInt)"
        rockLabel.text = rockString
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //If Dino3 runs into blocks
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Block && contact.bodyB.categoryBitMask == PhysicsCategory.Dino3) || (contact.bodyB.categoryBitMask == PhysicsCategory.Block && contact.bodyA.categoryBitMask == PhysicsCategory.Dino3){
            
            grid.dino3.removeAllActions()
            grid.whichDirectionDino3()
        }
        
   
        //If MazeMan runs into Dino1
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Dino1) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Dino1){
            
            self.takesDamage(damageAmount: 60)
        }
        

        //If MazeMan runs into Dino2
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Dino2) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Dino2){
            
            self.takesDamage(damageAmount: 80)
        }
        
        //If MazeMan runs into Dino3
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Dino3) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Dino3){
            
            self.takesDamage(damageAmount: 100)
        }
        
        //If MazeMan gets hit by Fireball
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Fireball) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Fireball){
            
            self.takesDamage(damageAmount: 100)
        }
        
        
        
        //If MazeMan falls into water
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Water) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Water){
            
            print("Drowned!!!")
            gameOver()
            
        }
        
        //If MazeMan runs into blocks
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Block) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Block){
            
       //     print("Ouch!")
            
        }
        
        //If MazeMan collects a star
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Star) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Star){
            
            print("Star!")
            self.increaseStar()
            self.grid.removeStar()
            self.changeMessageLabel(newText: "Cool! A star!!")
            
        }
        
        //If MazeMan eats food
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Caveman && contact.bodyB.categoryBitMask == PhysicsCategory.Food) || (contact.bodyB.categoryBitMask == PhysicsCategory.Caveman && contact.bodyA.categoryBitMask == PhysicsCategory.Food){
            
            
            self.changeMessageLabel(newText: "MazeMan sure was hungry!!")
            print("Yum!")
            increaseEnergy(addAmount: 50)
            self.grid.removeFoodCaveman()
            //add to battery and life
            // self.grid.addFood()
            
        }
            
            //If a Dino eats food
        else if ((contact.bodyA.categoryBitMask == PhysicsCategory.Food && contact.bodyB.categoryBitMask == PhysicsCategory.Dino1) || (contact.bodyB.categoryBitMask == PhysicsCategory.Food && contact.bodyA.categoryBitMask == PhysicsCategory.Dino1))
            || ((contact.bodyA.categoryBitMask == PhysicsCategory.Food && contact.bodyB.categoryBitMask == PhysicsCategory.Dino2) || (contact.bodyB.categoryBitMask == PhysicsCategory.Food && contact.bodyA.categoryBitMask == PhysicsCategory.Dino2))
            || ((contact.bodyA.categoryBitMask == PhysicsCategory.Food && contact.bodyB.categoryBitMask == PhysicsCategory.Dino3) || (contact.bodyB.categoryBitMask == PhysicsCategory.Food && contact.bodyA.categoryBitMask == PhysicsCategory.Dino3)) {
            
         //   print("Hungry Dino!")
            self.grid.removeFoodDino()
          //  self.changeMessageLabel(newText: "Dinos love to eat too!")
        }
        
        else {
        
        //If MazeMan's rock hits Dino1
        if (contact.bodyA.categoryBitMask == PhysicsCategory.Rock && contact.bodyB.categoryBitMask == PhysicsCategory.Dino1) || (contact.bodyB.categoryBitMask == PhysicsCategory.Rock && contact.bodyA.categoryBitMask == PhysicsCategory.Dino1) {
            
            self.changeMessageLabel(newText: "Nice Shot MazeMan!")
            self.grid.removeDino1()
            dino1Hit = true

        
        }
        
    
        
    
   else if (contact.bodyA.categoryBitMask == PhysicsCategory.Rock && contact.bodyB.categoryBitMask == PhysicsCategory.Dino2) || (contact.bodyB.categoryBitMask == PhysicsCategory.Rock && contact.bodyA.categoryBitMask == PhysicsCategory.Dino2) {
    
    
    self.changeMessageLabel(newText: "Nice Shot MazeMan!")
    
            self.grid.removeDino2()
    
    }
    
   else if (contact.bodyA.categoryBitMask == PhysicsCategory.Rock && contact.bodyB.categoryBitMask == PhysicsCategory.Dino3) || (contact.bodyB.categoryBitMask == PhysicsCategory.Rock && contact.bodyA.categoryBitMask == PhysicsCategory.Dino3){
    
    
    self.changeMessageLabel(newText: "Nice Shot MazeMan!")
    
            self.grid.removeDino3()
    
            }
    }
}

func changeMessageLabel(newText: String) {
    
    self.messageLabel.text = newText
    self.messageLabel.alpha = 1.0
    
    
    self.messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
}


override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //  if let label = self.label {
    //      label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
    //  }
    
  //  for t in touches { self.touchDown(atPoint: t.location(in: self)) }
}

override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
 //   for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  //  for t in touches { self.touchUp(atPoint: t.location(in: self)) }
}

override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
  //  for t in touches { self.touchUp(atPoint: t.location(in: self)) }
}



//   override func update(_ currentTime: TimeInterval) {
// Called before each frame is rendered
//   }

func updateWithTimeSinceLastUpdate(timeSinceLast: CFTimeInterval) {
    
    lastEnergyTimeInterval = timeSinceLast + lastEnergyTimeInterval
    lastRockTimeInterval = timeSinceLast + lastRockTimeInterval
    lastBlockTimeInterval = timeSinceLast + lastBlockTimeInterval
    lastFireTimeInterval = timeSinceLast + lastFireTimeInterval
    lastGravityTimeInterval = timeSinceLast + lastGravityTimeInterval
    
    /*
     a) Life: Initially player will have 3 additional lives (hearts). Every time its energy becomes
     zero, it loses one heart.
     b) Energy: 1 Life (heart) is 100 energy. Every second it loses 1 energy. It can gain energy
     by eating the food (50 energy). It loses energy if contacts to enemies. As the player can
     have max 3 additional hearts, including its own energy, this will be equa
     */
    if lastEnergyTimeInterval >= 1.0 {
        lastEnergyTimeInterval = 0
        decreaseEnergy(subtractAmount: 1)
    }
    
  //  else {
    //    lastEnergyTimeInterval = 0
       // decreaseHeart()
       // batteryInt = 100
  //  }
    
    if lastRockTimeInterval >= 30.0 && rockInt < 20 {
        lastRockTimeInterval = 0
        increaseRock()
    }
    
    
    if lastBlockTimeInterval > 1.0 && blockCount < 15 {
        lastBlockTimeInterval = 0
        grid.addBlock()
        blockCount+=1
    }
    if lastFireTimeInterval >= 5.0 {
        lastFireTimeInterval = 0
        grid.fireball.removeFromParent()
        grid.addFireball()
    }
    
    if lastGravityTimeInterval > 30.0 {
        lastGravityTimeInterval = 0
        
        messageLabel.removeFromParent()
        messageLabel = SKLabelNode(text: "Watch out for Gravity!!!")
        messageLabel.position = CGPoint(x: size.width/2, y: size.height-74)
        messageLabel.fontSize = 30
        messageLabel.fontColor = SKColor.white
        messageLabel.fontName = "Courier-Bold"
        messageLabel.zPosition = 1
        self.addChild(messageLabel)
        messageLabel.run(SKAction.fadeOut(withDuration: 5.0))
        
        gravityOn()
    }
}

override func update(_ currentTime: CFTimeInterval) {
    var timeSinceLast = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    if timeSinceLast > 1.0 {
        timeSinceLast = 1.0 / 60.0
        lastUpdateTimeInterval = currentTime
    }
    updateWithTimeSinceLastUpdate(timeSinceLast: timeSinceLast)
}


func newProjectile () -> Void {
    // if rockReady() == true {
    rockThrow = Rock().newRock
    let rockTexture = SKTexture(imageNamed: "rock")
    rockThrow = SKSpriteNode(texture: rockTexture)
   // rockThrow.name = "rock"
    rockThrow.zPosition = 5
    //  rockThrow.position = caveman.position
    rockThrow.physicsBody?.isDynamic = true
    rockThrow.physicsBody?.affectedByGravity = false
   // rockThrow.physicsBody?.allowsRotation = false
    rockThrow.size = CGSize(width: 40, height: 40)
    rockThrow.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 40, height: 40))
    rockThrow.physicsBody?.categoryBitMask = PhysicsCategory.Rock
    rockThrow.physicsBody?.collisionBitMask = PhysicsCategory.None
    //PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3
    rockThrow.physicsBody?.contactTestBitMask = PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3 //| //PhysicsCategory.Wall
    // addChild(rockThrow)
   
    // }
    //  rockReady = true
}

func rockReady() -> Bool {
    
    if self.rockInt > 0 {
        print("rock ready!")
        return true
        
    }
    
    return false
}

    func gameOver(){
        // transition to game over scene
        Score.count = starInt
        hs.addHighScore()
        
        let flipTransition = SKTransition.fade(withDuration: 2.0)
            
            //SKTransition.doorsCloseHorizontal(withDuration: 1.0)
        let gameOverScene = GameOverScene(size: self.size, score: Score.count)
        gameOverScene.scaleMode = .aspectFill
        
        self.view?.presentScene(gameOverScene, transition: flipTransition)
        
        
    }
    
}


//    }

//}
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


