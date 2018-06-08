import Foundation
import LGComponents

protocol RealEstateBannerDelegate: class {
    func realEstateBannerPressed()
}

class RealEstateBanner: UIView {
    
    private let backgroundImage = UIImageView()
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: viewHeight)
    }
    
    private let viewHeight: CGFloat = 200
    weak var delegate: RealEstateBannerDelegate?
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        backgroundColor = .clear
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = UIImage(named: "realEstateBanner", in: R.bundle, compatibleWith: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(realEstateBannerPressed))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupLayout() {
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImage)
        backgroundImage.layout(with: self).fill()
    }
    
    @objc private func realEstateBannerPressed() {
        delegate?.realEstateBannerPressed()
    }
}
