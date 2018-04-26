//
//  GameScene.swift
//  wwdc emoji
//
//  Created by djepbarov on 17.04.2018.
//  Copyright © 2018 davut. All rights reserved.
//

import Foundation

//: A SpriteKit based Playground

import Foundation
import SpriteKit

// Physic categories
public struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Player    : UInt32 = 0b1
    static let Ground    : UInt32 = 0b10
    static let Emojies   : UInt32 = 0b100
}

protocol CollectingEmoji {
    func controlCollected(item: SKNode)
}

public class GameScene: SKScene, SKPhysicsContactDelegate, Emojies, BlinkingPlayer, CollectingEmoji {
    
    var timerEnded = false
    
    var player: SKSpriteNode?
    
    var label: SKLabelNode?
    
    var emojies: [String] = ["😜","😍","🙃","😈","🤥","🤓","😎","🤢"]
    
    var fadeIn = SKAction.fadeIn(withDuration: 1)
    
    var fadeInOut = SKAction.sequence([.fadeIn(withDuration: 0.5),
                                       .fadeOut(withDuration: 0.5)])
    var fadeOut = SKAction.fadeOut(withDuration: 0.3)
    
    //var timerLabel = SKLabelNode().pointsAndTimer
    
    var playerTexts = ["Yes", "Maybe", "OK"]
    
    
//    var timerValue: Int = 120 {
//        didSet {
//            timerLabel.text = "Time Left: \(timerValue)"
//        }
//    }
    
    // Points that changes level
    //private var levels = [1,2,3,4,5,6]
    // Gravity of emojies
    //private var emojiGravity = [-0.6,-0.8,-1,-1.2,-1.3,-1.5]
    // Creating speed of new emojies
    //private var emojiCreatingSpeed = [0.5,0.4,0.3,0.2,0.1,0.09]
    
    // Progress for wwdc images
    private var progressFinised = false
    private var gravity = -0.6
    private var emojiCreatingSpeed = 0.5
    private var _level:CGFloat = 1
    private var level:CGFloat {
        get { return _level }
        set {
            //if !(gravity >= -9.8) {
                gravity -= 0.2
            //}
            if !(emojiCreatingSpeed <= 0.3) {
                emojiCreatingSpeed -= 0.1
            }
        }
    }
    
    // 🤟🏻, ✌🏻, ☝🏻
    var startCounterLabel : SKLabelNode!
    
    
    var ground : SKSpriteNode!
    var startButton = UIButton()
    var totalPointsLabel = SKLabelNode(text: "Points: 0").pointsAndTimer
    var lives = SKLabelNode(text: "💛💛💛")
    
    private var _totalPoints = 0
    
    var totalPoints: Int {
        get {
            return _totalPoints
        }
        set {
            let value = max(min(newValue,15),0)
            _totalPoints = value
        }
        
    }
    
    var firstEmoji = ""
    
    // Player can move
    var canMove = false
    
    // Setting Up
    override public func didMove(to view: SKView) {
        
        player = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "player")))
        
        let backgroundSound = SKAudioNode(fileNamed: "background")
        backgroundSound.name = "backgroundSound"
        self.addChild(backgroundSound)
        
        let centerX = self.view?.center.x
        let centerY = self.view?.center.y
        
        player?.name = "player"
        
        physicsWorld.contactDelegate = self
        
        startButton.createRoundedButton(x: centerX!, y: centerY!, title: "Play")
        startButton.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        self.view?.addSubview(startButton)
        
        startCounterLabel = childNode(withName: "//emojiLabel") as? SKLabelNode
        startCounterLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        
        startCounterLabel.alpha = 0.0
        let playerWidth: CGFloat = 250
        let playerHeight: CGFloat = 250
        player?.position = CGPoint(x: frame.width / 2, y: frame.maxY - (playerHeight / 2))
        player?.size = CGSize(width: playerWidth, height: playerHeight)
        self.addChild(self.player!)
        start()
        physicsWorld.gravity = CGVector.init(dx: 0, dy: gravity)
    }
    
    // Adds new emoji in random x position in 'TimeInterval'
    func fallingEmojies(every second: TimeInterval){
//        if timerEnded {
//            return
//        }
        guard !progressFinised else {
            for child in children {
                if child.name == "emojies" {
                    child.run(SKAction.fadeOut(withDuration: 1), completion: {
                        child.removeFromParent()
                        self.player?.removeAllChildren()
                    })
                }
            }
            return
        }
        
        var speedInSeconds = second
//        for (index, level) in levels.enumerated() {
//            if progress > CGFloat(level) {
//                speedInSeconds = emojiCreatingSpeed[index]
//            }
//        }
        speedInSeconds = emojiCreatingSpeed
        after(speedInSeconds) {
            let newSKLabel = SKLabelNode()
            self.label = newSKLabel
            let randomX = CGFloat(arc4random_uniform(UInt32(self.size.width - 10)))
            let newEmoji = self.newEmoji(at: CGPoint(x: randomX, y: self.size.height + 100))
            self.addChild(newEmoji)
            self.fallingEmojies(every: speedInSeconds)
        }
    }
    
    // Start button for very beginning
    @objc func startButtonPressed() {
        player?.run(SKAction.fadeOut(withDuration: 1))
        startButton.removeFromSuperview()
        
        startCounterLabel.run(fadeInOut) {
            self.startCounterLabel.text = "✌🏻"
            self.startCounterLabel.run(self.fadeInOut, completion: {
                self.startCounterLabel.text = "☝🏻"
                self.startCounterLabel.run(self.fadeInOut, completion: {
                    self.letTheGameStart()
                })
            })
        }
    }
    
//    func setupWWDCImage(){
//        wwdcImage.position = CGPoint(x: frame.midX, y: frame.maxY - (wwdcImage.frame.height + 30))
//        wwdcImage.run(SKAction.sequence([fadeIn]))
//        self.addChild(wwdcImage)
//    }
    
    func setupLives() {
        lives.position = CGPoint(x: frame.maxX - (lives.frame.width), y: frame.maxY - 50)
        self.addChild(lives)
        lives.fontSize = 40
    }
    
    func setupTotalPointsLabel() {
        totalPointsLabel.position = CGPoint(x: frame.minX + (totalPointsLabel.frame.width), y: frame.maxY - 50)
        self.addChild(totalPointsLabel)
    }
    
    func setupGround() {
        ground = SKSpriteNode(imageNamed: "ground2").ground
        ground.position = CGPoint(x: frame.width / 2, y: 50)
        ground.size = CGSize(width: frame.size.width, height: 200)
        ground.physicsBody = SKPhysicsBody(edgeFrom: CGPoint.init(x: -(self.ground.size.width / 2), y: 20), to: CGPoint.init(x: frame.maxX + 100, y: 20))
        self.addChild(self.ground)
    }
    
    func setupPlayer() {
        let move = SKAction.move(to: CGPoint(x: frame.midX, y: frame.minY + ground.frame.height), duration: 0.5)
        player?.run(SKAction.sequence([move,fadeIn]))
        player?.size = CGSize(width: 80, height: 80)
        player?.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        player?.physicsBody = SKPhysicsBody(circleOfRadius: ((player?.size.height)! / 2) - 10)
        player?.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player?.physicsBody?.contactTestBitMask = PhysicsCategory.Ground
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.mass = 100
        player?.zPosition = 0
        canMove = true
    }
    
//    func setupTimer() {
//        timerLabel.text = "Time Left: \(timerValue)"
//        timerLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
//        let wait = SKAction.wait(forDuration: 1)
//        let block = SKAction.run({
//            if self.timerValue > 0{
//                self.timerValue -= 1
//            }
//            else if !self.timerEnded {
//                // MARK: Time over
//                self.timerEnded = true
//                self.childNode(withName: "backgroundSound")?.removeFromParent()
//                self.run(SKAction.playSoundFileNamed("fail.mp3", waitForCompletion: false))
//                let timeOver = SKLabelNode(text: "Time is Over :(").gameOver
//                timeOver.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//                self.addChild(timeOver)
//                timeOver.run(self.fadeIn)
//            }
//        })
//        let sequence = SKAction.sequence([wait,block])
//        timerLabel.run(SKAction.repeatForever(SKAction.sequence([sequence])))
//        self.addChild(timerLabel)
//    }
    
    func setupClouds() {
        
        let cloud = SKSpriteNode(texture: SKTexture(imageNamed: "cloud")).cloud
        cloud.position = totalPointsLabel.position
        self.addChild(cloud)
        cloud.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: totalPointsLabel.frame.maxX, duration: 2), SKAction.moveTo(x: totalPointsLabel.frame.minX, duration: 2)])))
        
//        let cloud2 = SKSpriteNode(texture: SKTexture(imageNamed: "cloud2")).cloud
//        cloud2.position = timerLabel.position
//        self.addChild(cloud2)
//        cloud2.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: timerLabel.frame.maxX, duration: 2), SKAction.moveTo(x: timerLabel.frame.minX, duration: 2)])))
        
        let cloud3 = SKSpriteNode(texture: SKTexture(imageNamed: "cloud")).cloud
        cloud3.position = lives.position
        self.addChild(cloud3)
        cloud3.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveTo(x: lives.frame.maxX, duration: 2), SKAction.moveTo(x: lives.frame.minX, duration: 2)])))
        
    }
    
    // Game starts here
    func letTheGameStart(){
        setupTotalPointsLabel()
        setupLives()
        setupGround()
        setupPlayer()
//        setupWWDCImage()
       // setupTimer()
        fallingEmojies(every: emojiCreatingSpeed)
        setupClouds()
    }
    
    // Touching the bodies
    public func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ground" && contact.bodyB.node?.name == "emojies" {
            let emoji = contact.bodyB.node as? SKLabelNode
            emoji?.run(SKAction.fadeOut(withDuration: 1))
            emoji?.removeFromParent()
            if emoji?.text == firstEmoji {
                //totalPoints -= 1
                //totalPointsLabel.text = "Points: \(totalPoints)"
                //let minusOne = SKLabelNode(text: "-1")
                //minusOne.position = CGPoint(x:(emoji?.frame.midX)!,y:(emoji?.frame.midY)!)
                //minusOne.fontColor = .black
                //minusOne.fontSize = 50
                //self.addChild(minusOne)
                //let moveUp = SKAction.move(by: CGVector.init(dx: 0, dy: 20), duration: 1)
                //minusOne.run(SKAction.sequence([fadeIn,moveUp,fadeOut]), completion: {
                //  minusOne.removeFromParent()
                //})
            }
        }
        else if contact.bodyA.node?.name == "player" && contact.bodyB.node?.name == "emojies" {
            let emoji = contact.bodyB.node as? SKLabelNode
            let chosenEmoji = SKLabelNode(text: "\((emoji?.text)!)")
            controlCollected(item: chosenEmoji)
            emoji?.removeFromParent()
        }
//        else if contact.bodyA.node?.name == "WWDC" && contact.bodyB.node?.name == "player" {
//            let wwdc = contact.bodyA.node
//            let player = contact.bodyB.node
//            player?.removeAllChildren()
//            wwdc?.removeAllChildren()
//            controlCollected(item: wwdc!)
//
//        }
    }
    
    // Control falling emojies
    func controlCollected(item: SKNode) {
        guard let collectedEmoji = item as? SKLabelNode else {
            return
        }
        
        // MARK: Collected Emoji
        collectedEmoji.fontSize = 50
        
        // Little animation by rotating emojies
        func letEmojiDance() {
            let rotateToRight = SKAction.rotate(byAngle: 0.3, duration: 0.2)
            let rotateBack = SKAction.rotate(byAngle: 0, duration: 0.1)
            let rotateToLeft = SKAction.rotate(byAngle: -0.3, duration: 0.2)
            collectedEmoji.run(SKAction.repeatForever(SKAction.sequence([rotateToRight, rotateBack, rotateToLeft])))
        }
        letEmojiDance()
        
        
        let numberOfChildren = player?.children.count
        
        switch numberOfChildren {
        case 0?:
            player?.addChild(collectedEmoji)
            collectedEmoji.position = CGPoint(x: 0, y: 50)
            firstEmoji = collectedEmoji.text!
            self.run(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false))
        case 1? , 2?:
            if collectedEmoji.text != firstEmoji{
                // MARK: Lost live
                if (lives.text?.count)! > 1 {
                    lives.text?.removeLast()
                    self.run(SKAction.playSoundFileNamed("ouch.mp3", waitForCompletion: false))
                    let lost💛 = SKLabelNode(text: "💛")
                    lost💛.fontSize = 50
                    lost💛.position = CGPoint(x: frame.midX, y: (player?.frame.midY)! - 80)
                    fadeInOut = SKAction.sequence([.fadeIn(withDuration: 0.25),
                                                   .fadeOut(withDuration: 0.25)])
                    lost💛.run(SKAction.repeat(fadeInOut, count: 3))
                    lost💛.zPosition = 1
                    self.addChild(lost💛)
                }
                else {
                    // MARK: Game Over
                    if (lives.text?.contains("💛"))! {
                        lives.text?.removeLast()
                        self.run(SKAction.playSoundFileNamed("ouch.mp3", waitForCompletion: false))
                        let gameOverLabel1 = SKLabelNode(text: "Oh No, no lives left").gameOver
                        let gameOverLabel2 = SKLabelNode(text: "Um, Never mind I can continue").gameOver
                        
                        gameOverLabel1.position = CGPoint(x: frame.midX, y: frame.midY)
                        gameOverLabel2.position = CGPoint(x: frame.midX, y: gameOverLabel1.frame.midY - 80)
                        
                        fadeIn = SKAction.fadeIn(withDuration: 3)
                        gameOverLabel1.run(fadeIn, completion: {
                            gameOverLabel2.run(self.fadeIn)
                            self.addChild(gameOverLabel2)
                        })
                        self.addChild(gameOverLabel1)
                        after(6, work: {
                            gameOverLabel2.removeFromParent()
                            gameOverLabel1.removeFromParent()
                        })
                    }
                }
                // Start with new emoji
                self.run(SKAction.playSoundFileNamed("ouch.mp3", waitForCompletion: false))
                player?.removeAllChildren()
                player?.addChild(collectedEmoji)
                collectedEmoji.position = CGPoint(x: 0, y: 50)
                firstEmoji = collectedEmoji.text!
                return
            }
            self.run(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false))
            player?.addChild(collectedEmoji)
            collectedEmoji.position = CGPoint(x: numberOfChildren == 1 ? 50 : -50, y: 35)
            // Collecting third emoji
            if numberOfChildren == 2 {
                self.run(SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false))
                firstEmoji = ""
                let points = SKLabelNode(text: "+3")
                points.fontSize = 100
                totalPoints += 3
//                progress += 1
                level += 1
                totalPointsLabel.text = "Points: \(totalPoints)"
//                for (index, level) in levels.enumerated() {
//                    if progress > CGFloat(level) {
//                        physicsWorld.gravity = CGVector(dx: 0, dy: emojiGravity[index])
//                    }
//                }
                physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
                points.position = CGPoint(x: 0, y: 50)
                let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.3)
                points.run(SKAction.sequence([moveUp, fadeOut]))
                if let salute = SKEmitterNode(fileNamed: "Boom") {
                    salute.position = CGPoint(x: 0, y: 100)
                    self.player?.addChild(salute)
                }
                self.player?.addChild(points)
                after(0.6, work: {
                    self.player?.removeAllChildren()
                })
            }
        default:
            player?.removeAllChildren()
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if canMove {
            player?.run(SKAction.moveTo(x: pos.x, duration: 0.5))
            player?.run(SKAction.rotate(toAngle: pos.x > (player?.position.x)! ? -0.3 : 0.3, duration: 0.1))
        }
        
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchMoved(toPoint: t.location(in: self)) }
        
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.run(SKAction.rotate(toAngle: 0, duration: 0.1))
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
        
    }
    
    override public func update(_ currentTime: TimeInterval) {
        // Removing emojies that are out of screen size
        self.enumerateChildNodes(withName: "emojies") { (node: SKNode, nil) in
            if node.position.y < 0 || node.position.x > self.frame.maxX || node.position.x < self.frame.minX{
                node.removeFromParent()
            }
        }
    }
}

// Extensions
extension UIButton {
    func createRoundedButton(x: CGFloat, y: CGFloat, title: String) {
        let width: CGFloat = 100
        let height: CGFloat = 30
        self.frame = CGRect(x: x - (width / 2), y: y - (height / 2), width: width, height: height)
        self.setTitle(title, for: .normal)
        self.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.cornerRadius = 15
        self.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
    }
}

extension SKLabelNode {
    var scholarship: SKLabelNode {
        self.fontColor = .black
        return self
    }
    
    var gameOver : SKLabelNode {
        self.fontColor = .black
        self.fontSize = 70
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height))
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
        self.alpha = 0
        return self
    }
    
    var 🤟🏻hand: SKLabelNode {
        self.fontSize = 50
        self.text = "🤟🏻"
        return self
    }
    
    var pointsAndTimer: SKLabelNode {
        self.fontSize = 40
        self.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        return self
    }
    
    var status: SKLabelNode {
        self.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.fontSize = 40
        return self
    }
}


extension SKSpriteNode {
    
    var wwdcImageDone: SKSpriteNode {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: self.frame.height))
        self.physicsBody?.categoryBitMask = PhysicsCategory.Emojies
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.allowsRotation = false
        self.name = "WWDC"
        return self
    }
    
    var ground: SKSpriteNode {
        self.name = "ground"
        self.zPosition = -1
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 50))
        return self
    }
    
    var cloud: SKSpriteNode {
        self.zPosition = -1
        self.scale(to: CGSize(width: self.size.width * 1.5, height: self.size.height * 1.5))
        return self
    }
}





