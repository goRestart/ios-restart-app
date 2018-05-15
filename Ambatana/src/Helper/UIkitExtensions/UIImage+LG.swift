//
//  UIImage+LG.swift
//  LetGo
//
//  Created by Isaac Roldan on 21/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension UIImage {

    private var kLetGoUserImageSquareSize: CGFloat { return 1024 }
    
    func rotatedImage(_ clockWise: Bool = true) -> UIImage {
        
        UIGraphicsBeginImageContext(CGSize(width: size.height, height: size.width))
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: 0.5 * size.height, y: 0.5 * size.width)
        if clockWise {
            context.rotate(by: CGFloat(Double.pi/2))
        } else {
            context.rotate(by: CGFloat(-Double.pi/2))
        }
        context.translateBy(x: -0.5 * size.width, y: -0.5 * size.height)
        
        draw(at: CGPoint(x: 0, y: 0))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }

    func dataForAvatar() -> Data? {
        let size = CGSize(width: kLetGoUserImageSquareSize, height: kLetGoUserImageSquareSize)
        let resizedImage = self.resizedImageWithContentMode(.scaleAspectFill,
                                                            size: size,
                                                            interpolationQuality: .medium) ?? self
        let croppedImage = resizedImage.croppedCenteredImage() ?? resizedImage
        return UIImageJPEGRepresentation(croppedImage, 0.9)
    }
}

extension UIImage {
    static func imageFrom(url: URL) throws -> UIImage? {
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }
    
    func withAlpha(_ value: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
