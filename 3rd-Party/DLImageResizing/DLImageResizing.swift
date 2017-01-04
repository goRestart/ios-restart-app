//
//  DLImageResizing.swift
//  DLImageResizing
//
//  Created by Nacho on 9/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

extension UIImage {
    
    // MARK: - Image resizing.
    
    // Returns a copy of this image, cropped to certain bounds.
    func croppedImage(_ bounds: CGRect) -> UIImage? {
        guard let CGImage = cgImage else { return nil }
        guard let imageRef = CGImage.cropping(to: bounds) else { return nil }
        return UIImage(cgImage: imageRef, scale: 1.0, orientation: imageOrientation)
    }

    // Returns a copy of this image, cropped to its center.
    func croppedCenteredImage() -> UIImage? {
        let minSize = min(size.width, size.height)
        let originX = round((size.width - minSize) / 2.0)
        let originY = round((size.height - minSize) / 2.0)
        let bounds = CGRect(x: originX, y: originY, width: minSize, height: minSize)
        return croppedImage(bounds)
    }
    
    // Returns a copy of this image, squared to thumbnail size.
    // If transparentBorder is non-zero, adds a transparent border to the image, resulting in an antialiasing when 
    // rotating the image using CoreAnimation.
    func thumbnailImageOfSize(_ thumbnailSize: CGFloat, transparentBorder borderSize: UInt, cornerRadius: UInt, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        // first we resize the image to a thumbnail size
        guard let resizedImage = resizedImageWithContentMode(.scaleAspectFit, size: CGSize(width: thumbnailSize, height: thumbnailSize),
                                                             interpolationQuality: interpolationQuality) else { return nil }
        // then we crop the edges
        let croppedFrame = CGRect(x: round((resizedImage.size.width - thumbnailSize) / 2.0),
                                      y: round((resizedImage.size.height - thumbnailSize) / 2.0),
                                      width: thumbnailSize, height: thumbnailSize)
        let croppedImage = resizedImage.croppedImage(croppedFrame)
            
        // take transparent border into account
        let finalImage = borderSize > 0 ? croppedImage?.transparentBorderedImage(borderSize) ?? croppedImage : croppedImage
        // return final image
        return finalImage?.roundedCornersImageOfSize(CGFloat(cornerRadius), borderSize: borderSize)
    }
    
    // Returns a copy of the image, resized proportionally to a max side.
    func resizedImageToMaxSide(_ side: CGFloat, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        var w = size.width
        var h = size.height
        // resize to max size = kLetGoMaxProductImageSide
        
        let maxProductImageSide: CGFloat = 1024
        
        if w <= maxProductImageSide && h <= maxProductImageSide { return self }
        else if w > h { // cut width to maxProductImageSide and calculate height
            h = h * maxProductImageSide / w
            w = maxProductImageSide
        } else { // cut height to maxProductImageSide and calculate width
            w = w * maxProductImageSide / h
            h = maxProductImageSide
        }
        return resizedImageToSize(CGSize(width: w, height: h), interpolationQuality: interpolationQuality)
    }
    
    // Returns a copy of the image, resized to a new size with certain interpolation quality.
    func resizedImageToSize(_ size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        var needsToBeTransposed = false
        if imageOrientation == .left || imageOrientation == .leftMirrored || imageOrientation == .right || imageOrientation == .rightMirrored {
            needsToBeTransposed = true
        }
        return resizedImageToSize(size, transform: transformForOrientationWithSize(size),
                                  needsToBeTransposed: needsToBeTransposed, interpolationQuality: interpolationQuality)
    }
    
    // Returns a copy of the image, resized to match a content mode in certain bounds, with a given interpolation quality.
    func resizedImageWithContentMode(_ contentMode: UIViewContentMode, size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let horizontalRatio = size.width / self.size.width
        let verticalRatio = size.height / self.size.height
        var finalRatio: CGFloat
        
        switch (contentMode) {
        case .scaleAspectFill:
            finalRatio = max(horizontalRatio, verticalRatio)
        case .scaleAspectFit:
            finalRatio = min(horizontalRatio, verticalRatio)
        default:
            finalRatio = 1.0
        }
        
        let newSize = CGSize(width: self.size.width * finalRatio, height: self.size.height * finalRatio)
        return self.resizedImageToSize(newSize, interpolationQuality: interpolationQuality)
    }
    
    // Returns a copy of the image transformed by means of an affine transform and scaled to the new size.
    // Also, it sets the orientation to UIImageOrientation.Up.
    func resizedImageToSize(_ size: CGSize, transform: CGAffineTransform, needsToBeTransposed: Bool,
                            interpolationQuality: CGInterpolationQuality) -> UIImage? {
        // calculate frames and get initial CGImage
        let newFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
        guard let CGImage = cgImage, let colorSpace = CGImage.colorSpace else { return nil }
        
        // Generate a context for the new size
        guard let context = CGContext(data: nil, width: Int(newFrame.size.width), height: Int(newFrame.size.height),
                                                  bitsPerComponent: CGImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace,
                                                  bitmapInfo: CGImage.bitmapInfo.rawValue) else { return nil }
        // Apply transform to context.
        context.concatenate(transform);
        
        // Use quality level for interpolation.
        context.interpolationQuality = interpolationQuality;
        
        // Scale the image by drawing it in the resized context.
        context.draw(CGImage, in: needsToBeTransposed ? CGRect(x: 0, y: 0, width: newFrame.size.height, height: newFrame.size.width) :
                                                          newFrame)
        
        // Return the resized image from the context.
        guard let resultCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: resultCGImage)
    }
    
    // Returns a transform for correctly displaying the image given its orientation.
    func transformForOrientationWithSize(_ size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        // modify transform depending on side orientation
        if imageOrientation == .down || imageOrientation == .downMirrored { // EXIF 3 & 4
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        }
        else if imageOrientation == .left || imageOrientation == .leftMirrored { // EXIF 6 & 5
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        else if imageOrientation == .right || imageOrientation == .rightMirrored { // EXIF 7 & 8
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
        }
        
        // modify transform for mirrored orientations
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored { // EXIF 2 & 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        else if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored { // EXIF 5 & 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        
        return transform
    }
    
    // MARK: - Rounded corners.
    
    // Returns a copy of this image, with rounded corners.
    // If transparentBorder is non-zero, adds a transparent border to the image, resulting in an antialiasing when
    // rotating the image using CoreAnimation.
    func roundedCornersImageOfSize(_ size: CGFloat, borderSize: UInt) -> UIImage? {
        // We need an alpha layer in the image. Create a context
        guard let image = imageWithAlpha, let cgImage = image.cgImage else { return nil }
        guard let colorSpace = cgImage.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height),
                                                  bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                                                  space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
        // Create a clipping path with the rounded corners
        context.beginPath()


        addRoundedRectToPath(CGRect(x: CGFloat(borderSize), y: CGFloat(borderSize),
                             width: image.size.width - CGFloat(borderSize) * 2,
                             height: image.size.height - CGFloat(borderSize) * 2), context: context,
                             ovalWidth: size, ovalHeight: size)
        context.closePath()
        context.clip()
            
        // draw the image in the clipped context
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            
        // create the image and return it
        guard let clippedImage = context.makeImage() else { return nil }
        return UIImage(cgImage: clippedImage, scale: 1.0, orientation: imageOrientation)
    }
    
    // Creates a rounded rect to be added to a path in a drawing context
    func addRoundedRectToPath(_ rect: CGRect, context: CGContext, ovalWidth: CGFloat, ovalHeight: CGFloat) {
        // safety check: if we don't have a rect...
        if ovalWidth == 0 || ovalHeight == 0 { context.addRect(rect); return }
    
        context.saveGState();
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: ovalWidth, y: ovalHeight)
        let fw = rect.width / ovalWidth
        let fh = rect.height / ovalHeight
        context.move(to: CGPoint(x: fw, y: fh/2))
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1)
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1)
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1)
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1)
        context.closePath()
        context.restoreGState()
    }
    
    // MARK: - Alpha layers
    
    // Returns true if the image has an alpha channel.
    var hasAlphaChannel: Bool {
        guard let CGImage = cgImage else { return false }
        let alpha = CGImage.alphaInfo
        return (alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast)
    }
    
    // Returns a copy of the image after adding an alpha channel if needed
    var imageWithAlpha: UIImage? {
        if hasAlphaChannel { return nil }
        
        guard let CGImage = cgImage else { return nil }
        let width = CGImage.width
        let height = CGImage.height
        
        // bitsPerComponent and bitmapInfo hardcoded for avoiding an "unsupported parameter combination" error message
        let alphaInfoAsBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        guard let colorSpace = CGImage.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
                                                  bitmapInfo: CGBitmapInfo().union(alphaInfoAsBitmapInfo).rawValue)
            else { return nil }
        
        // draw the image in the context and return it
        context.draw(CGImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        guard let cgAlphaImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgAlphaImage, scale: 1.0, orientation: imageOrientation)
    }
    
    // Returns a copy of the image with a transparent border of certain size. Adds an alpha layer if necessary.
    func transparentBorderedImage(_ borderSize: UInt) -> UIImage? {
        guard let image = imageWithAlpha else { return nil }
        let newFrame = CGRect(x: 0, y: 0, width: image.size.width + CGFloat(borderSize)*2, height: image.size.height + CGFloat(borderSize)*2)
        // generate the context for drawing the image
        guard let CGImage = image.cgImage, let colorSpace = CGImage.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(newFrame.size.width), height: Int(newFrame.size.height),
                                                  bitsPerComponent: CGImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace,
                                                  bitmapInfo: CGImage.bitmapInfo.rawValue) else { return nil }
        // we'll draw the image at the center, with a space for the borders.
        let centerLocation = CGRect(x: CGFloat(borderSize), y: CGFloat(borderSize), width: image.size.width, height: image.size.height)
        context.draw(CGImage, in: centerLocation)
        guard let borderImage = context.makeImage() else { return nil }
        
        // create the transparent border image mask
        guard let maskImage = newBorderMask(borderSize, size: newFrame.size) else { return nil }
        guard let transparentBorderImage = borderImage.masking(maskImage) else { return nil }
        return UIImage(cgImage: transparentBorderImage, scale: 1.0, orientation: imageOrientation)
    }

    // Creates and returns a mask with transparent borders and opaque center content
    // Size must include the entire mask (opaque + transparent)
    func newBorderMask(_ borderSize: UInt, size: CGSize) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        // build a context for the new size
        let alphaInfoAsBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
                                                  bitmapInfo: CGBitmapInfo().union(alphaInfoAsBitmapInfo).rawValue)
            else { return nil }
        
        // we'll fill it initially with a transparent layer.
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // now the inner opaque part.
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: CGFloat(borderSize),
                          y: CGFloat(borderSize), width: size.width - CGFloat(borderSize) * 2,
                          height: size.height - CGFloat(borderSize) * 2))
        
        // return the image from the context
        return context.makeImage()
    }

}
