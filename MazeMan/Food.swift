//
//  Food.swift
//  MazeMan
//
//  Created by QC on 4/14/20.
//  Copyright © 2020 Quincey Cuthbert. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Food: SKSpriteNode{
    
        
    var newFood = SKSpriteNode(imageNamed: "food")

    func getFood() -> SKSpriteNode {
    return newFood
    }
    
}
