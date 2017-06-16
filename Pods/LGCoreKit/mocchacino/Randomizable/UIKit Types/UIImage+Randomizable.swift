import UIKit

extension UIImage: Randomizable {
    public static func makeRandom() -> Self {
        return makeRandom(width: Float.makeRandom(),
                          height: Float.makeRandom())
    }
}

public extension UIImage {
    static func makeRandom(width: Float, height: Float) -> Self {
        let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        let color = UIColor(red: CGFloat(Float.makeRandom(min: 0, max: 1)),
                            green: CGFloat(Float.makeRandom(min: 0, max: 1)),
                            blue: CGFloat(Float.makeRandom(min: 0, max: 1)),
                            alpha: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return self.init(cgImage: image.cgImage!)
    }
}
