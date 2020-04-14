//
//  Water.swift
//  MazeMan
//
//  Created by QC on 4/12/20.
//  Copyright © 2020 Quincey Cuthbert. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Water: SKSpriteNode{
    
        
    var newWater = SKSpriteNode(imageNamed: "water")
    var waterName = ""
        // block.size = CGSize(width: 64, height: 64)
    
    func setName(name: String) -> Void {
        waterName = name
        
    }
}
