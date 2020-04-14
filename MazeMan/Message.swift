//
//  Message.swift
//  MazeMan
//
//  Created by QC on 4/13/20.
//  Copyright © 2020 Quincey Cuthbert. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Message: SKSpriteNode {

func display(message:String) {
    let messageLabel: SKLabelNode = SKLabelNode(text: message)
    
    let messageX = -frame.width
    let messageY = frame.height/2.0
    messageLabel.position = CGPoint(x: messageX, y: messageY)
    
    messageLabel.horizontalAlignmentMode = .center
    messageLabel.fontName = "Courier-Bold"
    messageLabel.fontSize = 32.0
    messageLabel.zPosition = 10
    self.addChild(messageLabel)
    
    let messageAction = SKAction.fadeIn(withDuration: 5.0)
    messageLabel.run(messageAction)
}
}
