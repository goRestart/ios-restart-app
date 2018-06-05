import UIKit

/// View that simulates the Ken Burns effect (https://en.wikipedia.org/wiki/Ken_Burns_effect).
/// It has only been tested for portrait images which is our use case.
final class KenBurnsView: UIView {

    struct TransformationAttributes {
        let initialSize: CGSize
        let initialPosition: CGPoint
        let scale: CGFloat
        let translation: (x: CGFloat, y: CGFloat)
    }
    
    typealias Seconds = Double
    private struct Time {
        static let display: Seconds = 10
        static let transition: Seconds = 1
    }
    private var images = [UIImage]()
    private var currentImage: Int = -1
    private var timer: DispatchSourceTimer? = nil
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startAnimation(with images: [UIImage]) {
        guard timer == nil, !images.isEmpty  else { return }
        self.images = images
        startTimer()
    }
    
    func stopAnimation() {
        timer?.cancel()
    }
    
    deinit {
        stopAnimation()
    }
    
    // MARK: Private methods
    
    private func startTimer() {
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: Time.display)
        timer?.setEventHandler { [weak self] in self?.showNextImage() }
        timer?.resume()
    }
    
    private func showNextImage() {
        let image = nextImage()
        let transformation = randomTransformation(for: image)
        let imageView = newImageView(with: transformation.initialSize)
        
        let caLayer = addLayer(with: image,
                               to: imageView,
                               size: transformation.initialSize,
                               position: transformation.initialPosition)
        transform(caLayer: caLayer, with: transformation)
    }
    
    private func nextImage() -> UIImage {
        currentImage = (currentImage + 1) % images.count
        return images[currentImage]
    }
    
    private func randomTransformation(for image: UIImage) -> TransformationAttributes {
        let transformations = self.transformations(for: image)
        return transformations[Int(arc4random() % UInt32(transformations.count))]
    }
    
    private func transformations(for image: UIImage) -> [TransformationAttributes] {
        // This caculations are based on the fork of https://github.com/jberlana/JBKenBurns that we were using.
        let xRatio = bounds.width/image.size.width
        let yRatio = bounds.height/image.size.height
        let ratio = max(xRatio, yRatio) * 1.1
        let size = CGSize(width: image.size.width*ratio, height: image.size.height*ratio)
        let xPos = bounds.width - size.width
        let yPos = bounds.height - size.height
        let xDelta = (size.width-frame.size.width)/4
        let yDelta = (size.height-frame.size.height)/4
        
        return [
            TransformationAttributes(initialSize: size, initialPosition: CGPoint(x: 0, y: 0),
                                     scale: 1.25, translation: (x: -xDelta, y: -yDelta)),
            TransformationAttributes(initialSize: size, initialPosition: CGPoint(x: 0, y: yPos),
                                     scale: 1.10, translation: (x: -xDelta, y: yDelta)),
            TransformationAttributes(initialSize: size, initialPosition: CGPoint(x: xPos, y: 0),
                                     scale: 1.30, translation: (x: xDelta, y: -yDelta)),
            TransformationAttributes(initialSize: size, initialPosition: CGPoint(x: xPos, y: yPos),
                                     scale: 1.20, translation: (x: xDelta, y: yDelta)),
        ]
    }
    
    private func newImageView(with size: CGSize) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imageView.backgroundColor = .clear
        return imageView
    }
    
    private func addLayer(with image: UIImage, to imageView: UIImageView, size: CGSize, position: CGPoint) -> CALayer {
        let caLayer = CALayer()
        caLayer.contents = image.cgImage
        caLayer.anchorPoint = .zero
        caLayer.bounds = CGRect(origin: .zero, size: size)
        caLayer.position = position
        imageView.layer.addSublayer(caLayer)
        
        let animation = CABasicAnimation(keyPath:#keyPath(CALayer.opacity))
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = Time.transition
        caLayer.add(animation, forKey: nil)
        
        caLayer.opacity = 1.0
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [weak self] in
            if self?.subviews.count ?? 0 > 1 { self?.subviews.first?.removeFromSuperview() }
        })
        caLayer.add(animation, forKey: nil)
        CATransaction.commit()
        
        addSubview(imageView)
        return caLayer
    }
    
    private func transform(caLayer: CALayer, with attributes: TransformationAttributes) {
        var transform = CATransform3DMakeTranslation(attributes.translation.x, attributes.translation.y, 1.0)
        transform = CATransform3DScale(transform, attributes.scale, attributes.scale, 1.0)
        
        let transformAnimation = CABasicAnimation(keyPath:#keyPath(CALayer.transform))
        transformAnimation.fromValue = CATransform3DIdentity
        transformAnimation.toValue = transform
        transformAnimation.duration = Time.display
        
        caLayer.transform = transform
        caLayer.add(transformAnimation, forKey: nil)
    }
}

