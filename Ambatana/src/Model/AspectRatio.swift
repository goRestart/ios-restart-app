import Foundation

enum AspectRatio {
    case square, w4h3, w1h2, w9h16, custom(width: Int, height: Int)
    
    enum AspectRatioAttribute {
        case width, height
    }
    
    enum AspectRatioOrientation: Int {
        case portrait = 0, landscape, square
    }
    
    init(size: CGSize) {
        self = AspectRatio.custom(width: Int(size.width), height: Int(size.height))
    }
    
    private var refWidth: CGFloat {
        switch self {
        case .square: return 1.0
        case .w4h3: return 4.0
        case .w1h2: return 1.0
        case .w9h16: return 9.0
        case let .custom(width, _): return CGFloat(width)
        }
    }
    
    private var refHeight: CGFloat {
        switch self {
        case .square: return 1.0
        case .w4h3: return 3.0
        case .w1h2: return 2.0
        case .w9h16: return 16.0
        case let .custom(_, height): return CGFloat(height)
        }
    }
    
    var ratio: CGFloat {
        guard refHeight > 0 else { return 0 }
        return refWidth/refHeight
    }
    
    var orientation: AspectRatioOrientation {
        if ratio == 1 {
            return .square
        }
        return ratio > 1 ? .landscape : .portrait
    }
    
    /// Compares orientation to another aspect ratio. Returns true if the instance orientation is more
    /// pronounced. It returns false otherwise (eg: 3:1 "is more landscape" than 2:1).
    func isMore(_ oriented: AspectRatioOrientation, than otherAspectRatio: AspectRatio) -> Bool {
        switch oriented {
        case .square:
            return orientation == .square
        case .landscape:
            return ratio > otherAspectRatio.ratio
        case .portrait:
            return ratio < otherAspectRatio.ratio
        }
    }
    
    /// Given a value for one AspectRatioAttribute, returns a CGSize that conforms to the aspect ratio.
    func size(setting value: CGFloat, in attribute: AspectRatioAttribute) -> CGSize {
        let result: CGSize
        switch attribute {
        case .width:
            let inverseRatio = ratio != 0 ? 1/ratio : 0
            result = CGSize(width: value, height: value*inverseRatio)
        case .height:
            result = CGSize(width: value*ratio, height: value)
        }
        return result
    }
}

extension AspectRatio {
    func constrainedAspectRatio(_ oriented: AspectRatioOrientation, to otherAspectRatio: AspectRatio) -> AspectRatio {
        return isMore(.portrait, than: .w1h2) ? .w1h2 : self
    }
}

extension AspectRatio: Equatable {
    
    static func ==(lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        return lhs.ratio == rhs.ratio
    }
}
