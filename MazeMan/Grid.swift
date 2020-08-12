//
//  Grid.swift
//  MazeMan
//
//  Created by QC on 4/13/20.
//  Copyright © 2020 Quincey Cuthbert. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

struct touchPosition {
  public static var point = CGPoint(x: 0, y: 0)
  public static var initialized = false
}


class Grid: SKSpriteNode {
    
   // var caveman: SKSpriteNode!
    var food: SKSpriteNode!
    var foodXPos: Int!
    var foodYPos: Int!
    var star: SKSpriteNode!
    var dino1: SKSpriteNode!
    var dino2: SKSpriteNode!
    var dino3: SKSpriteNode!
    var water1: SKSpriteNode!
    var water1Pos: Int!
    var water2: SKSpriteNode!
    var water2Pos: Int!
    var dino4: SKSpriteNode!
    var fireball: SKSpriteNode!
    
    var rows: Int!
    var cols: Int!
    var blockSize: CGFloat!
    
    var sprites: Array2D<SKSpriteNode>!
    
    convenience init?(blockSize: CGFloat, rows: Int, cols: Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize, rows: rows, cols: cols)
            
            else {
                
                return nil
                
        }
        
        self.init(texture: texture, color: SKColor.clear, size: texture.size())
        // self.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.isUserInteractionEnabled = true
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
        self.sprites = Array2D(columns: 16, rows: 12, initialValue: Blank())
    }
    
    class func gridTexture(blockSize: CGFloat, rows: Int, cols: Int) -> SKTexture? {
        
        // Add 1 to the height and width to ensure the borders are within the sprite
        let size = CGSize(width: CGFloat(cols) * blockSize + 1.0, height: CGFloat(rows) * blockSize + 1.0)
        UIGraphicsBeginImageContext(size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let bezierPath = UIBezierPath()
        let offset:CGFloat = 0.5
        
        // Draw vertical lines
        for i in 0...cols {
            
            let x = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: x, y: 0))
            bezierPath.addLine(to: CGPoint(x: x, y: size.height))
        }
        
        // Draw horizontal lines
        for i in 0...rows {
            
            let y = CGFloat(i) * blockSize + offset
            bezierPath.move(to: CGPoint(x: 0, y: y))
            bezierPath.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        SKColor.clear.setStroke()
        bezierPath.lineWidth = 1.0
        bezierPath.stroke()
        context.addPath(bezierPath.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return SKTexture(image: image!)
    }
    
    func gridPosition(row:Int, col:Int) -> CGPoint {
        let offset = blockSize / 2.0 + 0.5
        let x = CGFloat(col) * blockSize - (blockSize * CGFloat(cols)) / 2.0 + offset
        let y = CGFloat(rows - row - 1) * blockSize - (blockSize * CGFloat(rows)) / 2.0 + offset
        return CGPoint(x:x, y:y)
    }
    
    func addWater(from: Int, to: Int) -> Void {
        
        let pos = Int.random(in: from..<to)
        var water = Water().newWater
        
        if pos < 9 {
            water1 = water
            water1Pos = pos
        }
            
        else {
            water2 = water
            water2Pos = pos
        }
        
        let waterTexture = SKTexture(imageNamed: "water")
        water = SKSpriteNode(texture: waterTexture)
        water.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 60))
        water.physicsBody?.isDynamic = false
        water.physicsBody?.categoryBitMask = PhysicsCategory.Water
        water.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Dino3
        water.physicsBody?.collisionBitMask = PhysicsCategory.Dino3
        
        water.position = gridPosition(row: 11, col: pos)
        water.size = CGSize(width: 64, height: 64)
        water.zPosition = 0.5
        
        let block = sprites[pos,11]
        block.removeFromParent()
        sprites[pos, 11] = water
        addChild(water)
    }
    
    
    func newRow(yPos: Int) -> Void {
        
        var count = 0
        for _ in 0 ..< 16 {
            var block = Block().newBlock
            
            let blockTexture = SKTexture(imageNamed: "block")
            block = SKSpriteNode(texture: blockTexture)
            block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            block.physicsBody?.isDynamic = false
            block.physicsBody?.categoryBitMask = PhysicsCategory.Wall
            block.physicsBody?.collisionBitMask = PhysicsCategory.Caveman | PhysicsCategory.Dino3
            block.physicsBody?.contactTestBitMask = PhysicsCategory.Dino3
            
            block.position = gridPosition(row: yPos, col: count)
            sprites[count, yPos] = block
            block.size = CGSize(width: 64, height: 64)
            block.zPosition = 0.25
            print(count)
            addChild(block)
            count+=1
        }
    }
    
    
    func newColumn(xPos: Int) -> Void {
        var count = 0
        for _ in -1 ..< 16 {
            var block = Block().newBlock
            
            let blockTexture = SKTexture(imageNamed: "block")
            block = SKSpriteNode(texture: blockTexture)
            block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            block.physicsBody?.isDynamic = false
            block.physicsBody?.categoryBitMask = PhysicsCategory.Wall
            block.physicsBody?.collisionBitMask = PhysicsCategory.Caveman | PhysicsCategory.Dino3
            block.physicsBody?.contactTestBitMask = PhysicsCategory.None
            
            block.position = gridPosition(row: count, col: xPos)
            
            block.size = CGSize(width: 64, height: 64)
            block.zPosition = 0.25
            print(count)
            addChild(block)
            count+=1
        }
    }
    
    
    func addBlock() -> Void {
        
        let xPos  = Int.random(in: 1..<16)
        let yPos = Int.random(in: 2..<11)
        
        var block = Block().newBlock
        
        let blockTexture = SKTexture(imageNamed: "block")
        block = SKSpriteNode(texture: blockTexture)
        block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        block.physicsBody?.isDynamic = false
        block.physicsBody?.categoryBitMask = PhysicsCategory.Block
        block.physicsBody?.collisionBitMask = PhysicsCategory.Caveman | PhysicsCategory.Dino3
        block.physicsBody?.contactTestBitMask = PhysicsCategory.Dino3
        
        block.position = gridPosition(row: yPos, col: xPos)
        
        if blockIsEmpty(x: xPos, y: yPos) {
            
            sprites[xPos, yPos] = block
            
        }
 
        block.size = CGSize(width: 64, height: 64)
        block.zPosition = 0.5
        self.addChild(block)
    }
    
    func addFood() -> Void {
        
        let xPos = Int.random(in: 1..<16)
        let yPos = Int.random(in: 2..<11)
        foodXPos = xPos
        foodYPos = yPos
        
        food = Food().newFood
        
        let foodTexture = SKTexture(imageNamed: "food")
        food = SKSpriteNode(texture: foodTexture)
        food.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        food.physicsBody?.isDynamic = false
        food.physicsBody?.categoryBitMask = PhysicsCategory.Food
        food.physicsBody?.collisionBitMask = PhysicsCategory.None
        food.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Dino1 | PhysicsCategory.Dino2 | PhysicsCategory.Dino3
        
        food.position = gridPosition(row: yPos, col: xPos)
        
        //  if sprites[xPos, yPos] != Block() && sprites[xPos, yPos] != Star() {
        if blockIsEmpty(x: xPos, y: yPos) {
            sprites[xPos, yPos] = food
            food.size = CGSize(width: 64, height: 64)
            food.zPosition = 0.5
            self.addChild(food)
        }
        else {
            addFood()
        }
    }
    
    func removeFoodCaveman() -> Void {
        
        sprites[foodXPos, foodYPos] = Blank()
        food.removeFromParent()
        self.addFood()
    }
    
    func removeFoodDino() -> Void {
        
        sprites[foodXPos, foodYPos] = Blank()
        food.removeFromParent()
        
        let delayTime = DispatchTime.now() + 10.0
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
            self.addFood()
            
            })
    }
    
    
    func blockIsEmpty(x: Int, y: Int) -> Bool {
        let xPos = x
        let yPos = y
        
        if sprites[xPos, yPos].isEqual(to: Blank()) {
            print("\(xPos),\(yPos)")
            return true
        }
        print("\(xPos),\(yPos) is occupied")
        return false
    }
    
    
    func addStar() -> Void {
        
        let xPos = Int.random(in: 1..<16)
        let yPos = Int.random(in: 2..<11)
        
        star = Star()
        
        let starTexture = SKTexture(imageNamed: "star")
        star = SKSpriteNode(texture: starTexture)
        star.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        star.physicsBody?.isDynamic = false
        star.physicsBody?.categoryBitMask = PhysicsCategory.Star
        star.physicsBody?.collisionBitMask = PhysicsCategory.None
        star.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman
        
        star.position = gridPosition(row: yPos, col: xPos)
        
        //   if sprites[xPos, yPos] != Block() && sprites[xPos, yPos] != Food() {
        if blockIsEmpty(x: xPos, y: yPos) {
            sprites[xPos, yPos] = star
            star.size = CGSize(width: 64, height: 64)
            star.zPosition = 0.5
            self.addChild(star)
        }
            
        else {
            
            self.addStar()
        }
        

    }
    
    func removeStar() -> Void {
      //  sprites[starXPos, starYPos] = Blank()
        star.removeFromParent()
        self.addStar()
    }
    
    func addDino1() -> Void {
        var xPos = 0
        var num = Int.random(in: 1..<11)
        dino1 = Dino1().newDino1
        
        if num % 2 == 1 {
            xPos = water1Pos
            print("dino1 at \(String(describing: water1Pos))")
            
        }
            
        else {
            xPos = water2Pos
            print("dino1 at \(String(describing: water2Pos))")

        }
        
        let dino1Texture = SKTexture(imageNamed: "dino1")
        dino1 = SKSpriteNode(texture: dino1Texture)
        dino1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        dino1.physicsBody?.isDynamic = true
        dino1.physicsBody?.affectedByGravity = false
        dino1.physicsBody?.allowsRotation = false
        dino1.physicsBody?.categoryBitMask = PhysicsCategory.Dino1
        dino1.physicsBody?.collisionBitMask = PhysicsCategory.None
        dino1.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Rock | PhysicsCategory.Food
        
        var yPos = 11
        dino1.position = gridPosition(row: yPos, col: xPos)
        
        dino1.size = CGSize(width: 64, height: 64)
        dino1.zPosition = 1
        self.addChild(dino1)
        
        let moveDown = SKAction.moveBy(x: 0.0, y: -576, duration: 3)
        let moveUp = SKAction.moveBy(x: 0.0, y: 576, duration: 3)
        let wait = SKAction.wait(forDuration: 3, withRange: 3)
        
        dino1.run(SKAction.sequence([SKAction.sequence([moveUp, moveDown]), (SKAction.repeatForever(SKAction.sequence([wait, moveUp, wait, moveDown])))])) {
            print("I moved!")
        }
    }
    
    func removeDino1() -> Void {
        dino1.removeAllActions()
        dino1.removeFromParent()
        
        respawnDino1()
            
    }
    
     
       func respawnDino1() -> Void {
       // let interval = Int.random(in: 1..<5)
      //  let delayTime = DispatchTime.now() + 3.0
      //  DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
        
             self.addDino1()
      //      })
       }
    
    
    func addDino2() -> Void {
        
        var yPos = Int.random(in: 2..<11)
        dino2 = Dino2()
        
        let dino2Texture = SKTexture(imageNamed: "dino2")
        dino2 = SKSpriteNode(texture: dino2Texture)
        dino2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        dino2.physicsBody?.isDynamic = true
        dino2.physicsBody?.affectedByGravity = false
        dino2.physicsBody?.allowsRotation = false
        dino2.physicsBody?.categoryBitMask = PhysicsCategory.Dino2
        dino2.physicsBody?.collisionBitMask = PhysicsCategory.None
        dino2.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Food | PhysicsCategory.Rock
        
        var xPos = 15
        dino2.position = gridPosition(row: yPos, col: xPos)
        
        dino2.size = CGSize(width: 64, height: 64)
        dino2.zPosition = 1
        self.addChild(dino2)
        
        let flipRight = SKAction.scaleX(to: -1, duration: 1)
        let flipLeft = SKAction.scaleX(to: 1, duration: 1)
        let moveLeft = SKAction.sequence([flipLeft, (SKAction.moveBy(x: -960, y: 0.0, duration: 4))])
        let moveRight = SKAction.sequence([flipRight, (SKAction.moveBy(x: 960, y: 0.0, duration: 4))])
        let wait = SKAction.wait(forDuration: 3, withRange: 3)
        dino2.run(SKAction.sequence([SKAction.sequence([moveLeft, moveRight]), (SKAction.repeatForever(SKAction.sequence([wait, moveLeft, wait, moveRight])))])) {
        }
        
    }
    
        func removeDino2() -> Void {
            dino2.removeAllActions()
            dino2.removeFromParent()
            
            respawnDino2()
        }
        
           func respawnDino2() -> Void {
                 self.addDino2()
           }
    
    func addDino3() -> Void {
        let xPos = 0
        let yPos = 2
        dino3 = Dino3()
        
        // let dino3Texture = SKSpriteNode(texture: spaceShipTexture)
        
        
        let dino3Texture = SKTexture(imageNamed: "dino3")
        dino3 = SKSpriteNode(texture: dino3Texture)
        
        dino3.physicsBody = SKPhysicsBody(texture: dino3Texture, size: CGSize(width: 64,height: 64))
        
        let xRange = SKRange(lowerLimit:-475,upperLimit: 475)
        let yRange = SKRange(lowerLimit:-285,upperLimit: 220)
        
        dino3.physicsBody?.isDynamic = true
        dino3.physicsBody?.affectedByGravity = false
        dino3.physicsBody?.allowsRotation = false
        dino3.physicsBody?.categoryBitMask = PhysicsCategory.Dino3
        dino3.physicsBody?.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Water | PhysicsCategory.Wall
        dino3.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Food | PhysicsCategory.Block | PhysicsCategory.Rock
        
        dino3.position = gridPosition(row: yPos, col: xPos)
        dino3.constraints = [SKConstraint.positionX(xRange, y: yRange)]
        
        dino3.size = CGSize(width: 64, height: 64)
        dino3.zPosition = 1
        self.addChild(dino3)
        
        whichDirectionDino3()
        
    }
    
    func whichDirectionDino3() -> Void {
        var flipRight = SKAction.scaleX(to: -1, duration: 1)
        var flipLeft = SKAction.scaleX(to: 1, duration: 1)
        var moveLeft = SKAction.sequence([flipLeft, (SKAction.moveBy(x: -960, y: 0.0, duration: 4))])
        var moveRight = SKAction.sequence([flipRight, (SKAction.moveBy(x: 960, y: 0.0, duration: 4))])
        var moveDown = SKAction.moveBy(x: 0.0, y: -576, duration: 3)
        var moveUp = SKAction.moveBy(x: 0.0, y: 576, duration: 3)
        
        var direction = SKAction()
        var numDirection = Int.random(in: 1..<5)
        
        if numDirection == 1 {
            direction = moveLeft
          //  print("left")
        }
        
        if numDirection == 2 {
            direction = moveRight
         //   print("right")
        }
        
        if numDirection == 3 {
            direction = moveUp
          //  print("up")
        }
            
        else {
            direction = moveDown
          //  print("down")
        }

        dino3.run(SKAction.sequence([direction, whichDirection()])) {
            self.whichDirectionDino3()
        }
        
    }
    
    func whichDirection() -> SKAction {
        let flipRight = SKAction.scaleX(to: -1, duration: 1)
        let flipLeft = SKAction.scaleX(to: 1, duration: 1)
        let moveLeft = SKAction.sequence([flipLeft, (SKAction.moveBy(x: -960, y: 0.0, duration: 4))])
        let moveRight = SKAction.sequence([flipRight, (SKAction.moveBy(x: 960, y: 0.0, duration: 4))])
        let moveDown = SKAction.moveBy(x: 0.0, y: -576, duration: 3)
        let moveUp = SKAction.moveBy(x: 0.0, y: 576, duration: 3)
        
        
        
        let whichDirection = Int.random(in: 1..<5)
        
        if whichDirection == 1 {

            return moveLeft
        }
        
        if whichDirection == 2 {

            return moveRight
        }
        
        if whichDirection == 3 {

            return moveUp
        }
            
        else {
            
        return moveDown
            
        }
    }
    
    
    func removeDino3() -> Void {
        dino3.removeAllActions()
        dino3.removeFromParent()
        
        respawnDino3()
            
    }
    
     
       func respawnDino3() -> Void {

             self.addDino3()
       }
    
    func addDino4() -> Void {
        
        let yPos = 1
        dino4 = Dino4()
        
        let dino4Texture = SKTexture(imageNamed: "dino4")
        dino4 = SKSpriteNode(texture: dino4Texture)
        dino4.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 64))
        dino4.physicsBody?.isDynamic = true
        dino4.physicsBody?.affectedByGravity = false
        dino4.physicsBody?.allowsRotation = false
        dino4.physicsBody?.categoryBitMask = PhysicsCategory.Dino4
        dino4.physicsBody?.collisionBitMask = PhysicsCategory.None
        dino4.physicsBody?.contactTestBitMask = PhysicsCategory.None
        
        let xPos = 0
        dino4.position = gridPosition(row: yPos, col: xPos)
        
        dino4.size = CGSize(width: 128, height: 64)
        dino4.zPosition = 1
        self.addChild(dino4)
        
        
        let moveLeft = SKAction.moveBy(x: -960, y: 0.0, duration: 6)
        let moveRight = SKAction.moveBy(x: 960, y: 0.0, duration: 6)
    //    let wait = SKAction.wait(forDuration: 2, withRange: 2)
        dino4.run(SKAction.repeatForever(SKAction.sequence([moveRight, moveLeft])))
        
    }
    
    
    func addFireball() {
        let fireballTexture = SKTexture(imageNamed: "fire")
        fireball = SKSpriteNode(texture: fireballTexture)

        fireball.position = dino4.position
        fireball.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        fireball.physicsBody?.isDynamic = true
        fireball.physicsBody?.affectedByGravity = false
        fireball.physicsBody?.allowsRotation = false
        fireball.physicsBody?.categoryBitMask = PhysicsCategory.Fireball
        fireball.physicsBody?.collisionBitMask = PhysicsCategory.None
        fireball.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman
      //  fireball.mass = 1.0
        
        fireball.size = CGSize(width: 64, height: 64)
        fireball.zPosition = 5
        
        self.addChild(fireball)
        
        let moveDown = SKAction.moveBy(x: 0.0, y: -800, duration: 3)
       // let wait = SKAction.wait(forDuration: 10, withRange: 10)
        //fireball.run(SKAction.sequence([wait, moveDown]))
        fireball.run(moveDown)
        
        //SKAction.removeFromParent()
    }
    
    func setUp() -> Void {
        
        newColumn(xPos: -1)
        newColumn(xPos: 16)
        newRow(yPos: 0)
        newRow(yPos: 1)
        newRow(yPos: 11)
        addWater(from: 1, to: 8)
        addWater(from: 9, to: 15)
     //   addCaveman()
        addDino1()
        addDino2()
        addDino3()
        addDino4()
        addFireball()
        addFood()
        addStar()
    }
    
    func tearDown() -> Void {
        
        removeAllChildren()
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            let position = touch.location(in: self)
            let node = atPoint(position)
            
                if node != self {
              //  let action = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
               // node.run(action)
            }
            else {
                let x = size.width / 2 + position.x
                let y = size.height / 2 - position.y
                let row = Int(floor(x / blockSize))
                let col = Int(floor(y / blockSize))
              //  print("\(row) \(col)")
            }
           
        }
        
       let tap = touches.first
            let tapLocation = tap!.location(in: self)
        touchPosition.point = tapLocation
    }
    
}

public struct Array2D<T> {
    
    public let columns: Int
    public let rows: Int
    fileprivate var array: [T]
    
    public init(columns: Int, rows: Int, initialValue: T) {
        
        self.columns = columns
        self.rows = rows
        array = .init(repeating: initialValue, count: rows * columns)
    }
    
    public subscript(column: Int, row: Int) -> T {
        
        get {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            return array[row*columns + column]
        }
        
        set {
            precondition(column < columns, "Column \(column) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            precondition(row < rows, "Row \(row) Index is out of range. Array<T>(columns: \(columns), rows:\(rows))")
            array[row*columns + column] = newValue
        }
    }
    
}
/*
 
 func random() -> CGFloat {
   return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
 }

 func random(min: CGFloat, max: CGFloat) -> CGFloat {
   return random() * (max - min) + min
 }
 */
