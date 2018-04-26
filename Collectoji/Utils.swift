import Foundation

public func after(_ interval: TimeInterval, work: @escaping () -> ()) {
    let time: DispatchTime = DispatchTime.now() + .milliseconds(Int(interval * 1000.0))
    DispatchQueue.main.asyncAfter(deadline: time) {
        work()
    }
}

public func randomInterval(between lowerBound: TimeInterval, and upperBound: TimeInterval) -> TimeInterval {
    let fixedPoint: TimeInterval = 1000
    let fixedLowerBound = Int(lowerBound * fixedPoint)
    let fixedUpperBound = Int(upperBound * fixedPoint)
    let delta = fixedUpperBound - fixedLowerBound
    let adjustment = Int(arc4random_uniform(UInt32(delta)))
    let result = lowerBound + TimeInterval(adjustment)/fixedPoint
    return result
}

