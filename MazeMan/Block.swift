//
//  Block.swift
//  
//
//  Created by QC on 4/12/20.
//

import UIKit
import SpriteKit
import GameplayKit

class Block: SKSpriteNode{
    
        
    var newBlock = SKSpriteNode(imageNamed: "block")
        // block.size = CGSize(width: 64, height: 64)
 

    func getBlock() -> SKSpriteNode {
    return newBlock
    }

}
