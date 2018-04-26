//
//  ProgressBar.swift
//  wwdc emoji
//
//  Created by djepbarov on 26.03.2018.
//  Copyright © 2018 davut. All rights reserved.
//

import Foundation
import SpriteKit

class ProgressBar:SKNode {
    private var background:SKSpriteNode?
    private var bar:SKSpriteNode?
    private var _progress:CGFloat = 1
    var done = false
    var progress:CGFloat {
        get {
            return _progress
        }
        set {
            let value = max(min(newValue,6),1)
            guard let bar = bar else { return }
            bar.run(SKAction.scaleX(to: value, duration: 0.5))// xScale = value
            _progress = value
            if newValue >= 1.0 {
                done = true
            }
        }
    }

    convenience init(color:SKColor, size:CGSize) {
        self.init()
        background = SKSpriteNode(color:SKColor.white,size:size)
        bar = SKSpriteNode(color:color,size:size)
        if let bar = bar, let background = background {
            bar.xScale = 0.0
            background.zPosition = 0.5
            bar.zPosition = 1
            bar.position = CGPoint(x:-size.width/2,y:0)
            bar.anchorPoint = CGPoint(x:0.0,y:0.5)
            addChild(background)
            addChild(bar)
        }
    }
}


