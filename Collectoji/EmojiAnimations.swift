import UIKit
import SpriteKit

protocol BlinkingPlayer {
    var player: SKSpriteNode? {get set}
    func start()
    func planToBlink()
    func planToUnblink()
}

extension BlinkingPlayer {
    func start() {
        planToBlink()
    }
    
    func planToBlink() {
        let timeUntilBlink = randomInterval(between: 1, and: 3)
        after(timeUntilBlink) {
            self.player?.run(SKAction.setTexture(SKTexture(image: UIImage(named: "playerBlink")!)))
            self.planToUnblink()
        }
    }
    
    func planToUnblink() {
        let timeUntilUnblink = randomInterval(between: 0.05, and: 0.10)
        after(timeUntilUnblink) {
            self.player?.run(SKAction.setTexture(SKTexture(image: UIImage(named: "player")!)))
            self.planToBlink()
        }
    }
}
