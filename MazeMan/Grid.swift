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


class Grid: SKSpriteNode {
    
    var food: SKSpriteNode!
    var star: SKSpriteNode!
    var dino1: SKSpriteNode!
    var dino2: SKSpriteNode!
    var dino3: SKSpriteNode!
    var water1: SKSpriteNode!
    var water1Pos: Int!
    var water2: SKSpriteNode!
    var water2Pos: Int!
   // var dino4: SKSpriteNode!
    
    var rows: Int!
    var cols: Int!
    var blockSize: CGFloat!
    
    var sprites: Array2D<SKSpriteNode>!
    
    convenience init?(blockSize: CGFloat, rows: Int, cols: Int) {
        guard let texture = Grid.gridTexture(blockSize: blockSize, rows: rows, cols: cols)
            
            else {
                
            return nil
            
        }
        
        self.init(texture: texture, color: SKColor.white, size: texture.size())
        // self.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.isUserInteractionEnabled = true
        self.blockSize = blockSize
        self.rows = rows
        self.cols = cols
        self.sprites = Array2D(columns: 16, rows: 12, initialValue: SKSpriteNode())
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
        
        SKColor.white.setStroke()
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
        water.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        water.physicsBody?.isDynamic = false
        water.physicsBody?.categoryBitMask = PhysicsCategory.Water
        water.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman
        
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
            block.physicsBody?.categoryBitMask = PhysicsCategory.Block
            block.physicsBody?.collisionBitMask = PhysicsCategory.Caveman | PhysicsCategory.SpikesDino
            
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
            block.physicsBody?.categoryBitMask = PhysicsCategory.Block
            block.physicsBody?.collisionBitMask = PhysicsCategory.Caveman | PhysicsCategory.SpikesDino
            
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
        block.physicsBody?.collisionBitMask = PhysicsCategory.Caveman | PhysicsCategory.SpikesDino
        
        block.position = gridPosition(row: yPos, col: xPos)
        
        if blockIsEmpty(x: xPos, y: yPos) {
            
        sprites[xPos, yPos] = block
            
        }
        //y between 1 and 9
        
        block.size = CGSize(width: 64, height: 64)
        block.zPosition = 0.5
        self.addChild(block)
    }
    
    func addFood() -> Void {
        
        let xPos = Int.random(in: 1..<16)
        let yPos = Int.random(in: 2..<11)
        
        food = Food().newFood
        
        let foodTexture = SKTexture(imageNamed: "food")
        food = SKSpriteNode(texture: foodTexture)
        food.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        food.physicsBody?.isDynamic = false
        food.physicsBody?.categoryBitMask = PhysicsCategory.Food
        food.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Dino
        
        food.position = gridPosition(row: yPos, col: xPos)
        
      //  if sprites[xPos, yPos] != Block() && sprites[xPos, yPos] != Star() {
        if blockIsEmpty(x: xPos, y: yPos) {
            sprites[xPos, yPos] = food
        }
        else {
            
            addFood()
        }
        
        food.size = CGSize(width: 64, height: 64)
        food.zPosition = 0.5
        self.addChild(food)
    }
    
    func removeFood() -> Void {
        
        food.removeFromParent()
    }
    
    func blockIsEmpty(x: Int, y: Int) -> Bool {
        let xPos = x
        let yPos = y
        
        if sprites[xPos, yPos] == Block().newBlock || sprites[xPos, yPos] == food || sprites[xPos , yPos] == star {
            print("\(xPos),\(yPos) is occupied")
            return false
      }
        print("\(xPos),\(yPos)")
        return true
    }
    

    func addStar() -> Void {
        
        let xPos = Int.random(in: 1..<16)
        let yPos = Int.random(in: 2..<11)
        
        star = Star().newStar
        
        let starTexture = SKTexture(imageNamed: "star")
        star = SKSpriteNode(texture: starTexture)
        star.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        star.physicsBody?.isDynamic = false
        star.physicsBody?.categoryBitMask = PhysicsCategory.Star
        star.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman
        
        star.position = gridPosition(row: yPos, col: xPos)
        
     //   if sprites[xPos, yPos] != Block() && sprites[xPos, yPos] != Food() {
        if blockIsEmpty(x: xPos, y: yPos) {
            sprites[xPos, yPos] = star
        }
        
        else {
            
            self.addStar()
        }
        
        star.size = CGSize(width: 64, height: 64)
        star.zPosition = 0.5
        self.addChild(star)
    }
    
    func removeStar() -> Void {
        
        star.removeFromParent()
    }
    
    func addDino1() -> Void {
        var xPos = 0
        let num = Int.random(in: 1..<11)
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
        dino1.physicsBody?.allowsRotation = true
        dino1.physicsBody?.categoryBitMask = PhysicsCategory.Dino
        dino1.physicsBody?.collisionBitMask = PhysicsCategory.Caveman
        dino1.physicsBody?.contactTestBitMask = PhysicsCategory.Caveman | PhysicsCategory.Food
        
        let yPos = 11
        dino1.position = gridPosition(row: yPos, col: xPos)
        
        dino1.size = CGSize(width: 64, height: 64)
        dino1.zPosition = 1
        self.addChild(dino1)
        
        let moveDown = SKAction.moveBy(x: 0.0, y: -576, duration: 3)
        let moveUp = SKAction.moveBy(x: 0.0, y: 576, duration: 3)
        let wait = SKAction.wait(forDuration: 3, withRange: 3)
        dino1.run(SKAction.sequence([SKAction.sequence([moveUp, moveDown]), (SKAction.repeatForever(SKAction.sequence([moveUp, wait, moveDown, wait])))])) {
            print("I moved!")
        }

        
 /*
         
         let moveLeft = SKAction.moveBy(x: -size.width - dino1.size.width, y: 0.0, duration: 3)
         let moveRight = SKAction.moveBy(x: +size.width + dino1.size.width, y: 0.0, duration: 3)
         let wait = SKAction.wait(forDuration: 3, withRange: 3)
         dino1.run(SKAction.sequence([SKAction.sequence([moveLeft, moveRight]), (SKAction.repeatForever(SKAction.sequence([moveLeft, wait, moveRight, wait])))])) {
             print("I moved!")
         }
         */
       // sprite.runAction(SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight])))
        
       // dino1.runAction(SKAction.moveByX(-size.width - dino1.size.width, y: 0.0,
                       //  duration: TimeInterval(random(min: 1, max: 2))))
    }
    
    func removeDino1() -> Void {
        
        dino1.removeFromParent()
    }
    
    func setUp() -> Void {
        
        newColumn(xPos: -1)
        newColumn(xPos: 16)
        newRow(yPos: 0)
        newRow(yPos: 1)
        newRow(yPos: 11)
        addWater(from: 1, to: 8)
        addWater(from: 9, to: 15)
        addDino1()
        addBlock()
        addBlock()
        addBlock()
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
                let action = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1)
                node.run(action)
            }
            else {
                let x = size.width / 2 + position.x
                let y = size.height / 2 - position.y
                let row = Int(floor(x / blockSize))
                let col = Int(floor(y / blockSize))
                print("\(row) \(col)")
            }
        }
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
