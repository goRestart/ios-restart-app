import LGCoreKit

extension LGSize {
    
    var toCGSize: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}
