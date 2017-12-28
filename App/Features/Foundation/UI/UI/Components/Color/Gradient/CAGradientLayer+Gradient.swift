import UIKit

extension CAGradientLayer: Gradient {
  static public var `default`: CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [
      UIColor.primary.cgColor,
      UIColor.primaryAlt.cgColor
    ]
    layer.locations = [0.0 , 1.0]
    layer.startPoint = CGPoint(x: 0.0, y: 1.0)
    layer.endPoint = CGPoint(x: 1.0, y: 1.0)
    return layer
  }
}
