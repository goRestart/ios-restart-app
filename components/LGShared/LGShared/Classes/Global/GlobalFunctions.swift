import Foundation

public func delay(_ time: Double, completion: @escaping (() -> Void)) {
    let delayTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        completion()
    }
}

public func onMainThread(_ completion: @escaping (() -> Void)) {
    DispatchQueue.main.async {
        completion()
    }
}
