import Foundation
import UIKit

final class GradientView: UIView {
    private var gradient: CAGradientLayer? { return self.layer as? CAGradientLayer }
    private let colors: [UIColor]
    private let locations: [Float]

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var startPoint: CGPoint? {
        didSet {
            guard let startPoint = startPoint else { return }
            gradient?.startPoint = startPoint
        }
    }
    var endPoint: CGPoint? {
        didSet {
            guard let endPoint = endPoint else { return }
            gradient?.endPoint = endPoint
        }
    }

    init(colors: [UIColor], locations: [Float] = [0 , 1]) {
        self.colors = colors
        self.locations = locations
        super.init(frame: .zero)
        self.isOpaque = false

        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayers() {
        gradient?.colors = colors.map { $0.cgColor }
        gradient?.locations = locations.map { NSNumber(value: $0) }
    }
}
