//
//  emojies.swift
//  wwdc emoji
//
//  Created by djepbarov on 23.03.2018.
//  Copyright © 2018 davut. All rights reserved.
//
import Foundation
import SpriteKit

protocol Emojies {
    var label: SKLabelNode? {get}
    var emojies: [String] {get set}
    func randomEmoji() -> String
    func newEmoji(at point: CGPoint) -> SKLabelNode
}

extension Emojies {
    
    func randomEmoji() -> String {
        let numberOfEmojies = emojies.count
        let random = Int(arc4random_uniform(UInt32(numberOfEmojies)))
        return emojies[random]
    }
    
    func newEmoji(at point: CGPoint) -> SKLabelNode {
        label?.fontSize = 70
        label?.position = point
        label?.zPosition = 0
        label?.text = randomEmoji()
        label?.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        label?.physicsBody?.categoryBitMask = PhysicsCategory.All
        label?.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        label?.physicsBody?.collisionBitMask = PhysicsCategory.Emojies
        label?.physicsBody?.friction = 0
        label?.name = "emojies"
        return label!
    }
}
