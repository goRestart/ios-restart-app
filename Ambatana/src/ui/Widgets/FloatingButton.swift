import UIKit
import LGComponents

enum FloatingIconPosition {
    case left
    case right
}

class FloatingButton: UIView {
    private static let titleIconSpacing: CGFloat = 10
    private static let sideMargin: CGFloat = 25
    private static let iconSize: CGFloat = 28

    private let containerView = UIView()
    private let icon = UIImageView(frame: CGRect.zero)
    private let iconPosition: FloatingIconPosition
    private let label = UILabel()
    private let button = LetgoButton(withStyle: .primary(fontSize: .big))
    private var widthConstraint = NSLayoutConstraint()

    var buttonTouchBlock: (() -> ())?

    // MARK: - Lifecycle
    
    init(with title: String, image: UIImage?, position: FloatingIconPosition) {
        icon.image = image
        iconPosition = position
        label.text = title

        super.init(frame: CGRect.zero)
        
        setupConstraints()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setRoundedCorners()
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: LGUIKitConstants.tabBarSellFloatingButtonHeight)
    }
    
    // MARK: - Setters

    func setIcon(with image: UIImage?) {
        icon.image = image
    }
    
    func setTitle(with string: String) {
        label.text = string
    }
    
    func hideWithAnimation() {
        let animations = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.alpha = 0
            strongSelf.setupConstraintsToHide()
            strongSelf.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.2, animations: animations, completion: nil)
    }
    
    func showWithAnimation() {
        let animations = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.alpha = 1
            strongSelf.setupConstraintsToShow()
            strongSelf.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, animations: animations, completion: nil)
    }

    // MARK: - Private methods

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(button)
        containerView.addSubview(icon)
        containerView.addSubview(label)
    
        let views = ["c": containerView, "b": button, "l": label, "i": icon]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[c]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[c]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[b]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[b]|", options: [], metrics: nil, views: views))

        let leftView = iconPosition == .left ? "i" : "l"
        let rightView = iconPosition == .left ? "l" : "i"
        let metrics = ["spacing": FloatingButton.titleIconSpacing, "margin": FloatingButton.sideMargin]
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[\(leftView)]-spacing-[\(rightView)]-margin-|",
            options: [], metrics: metrics, views: views))
        
        containerView.addConstraint(NSLayoutConstraint(item: icon, attribute: .centerY, relatedBy: .equal,
            toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal,
            toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        containerView.addConstraint(NSLayoutConstraint(item: icon, attribute: .width, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: FloatingButton.iconSize))
        containerView.addConstraint(NSLayoutConstraint(item: icon, attribute: .height, relatedBy: .equal,
            toItem: icon, attribute: .width, multiplier: 1, constant: 0))
    }
    
    private func setupConstraintsToHide() {
        layout().width(60, constraintBlock: { [weak self] constraint in
            self?.widthConstraint = constraint
        })
    }
    
    private func setupConstraintsToShow() {
        removeConstraint(widthConstraint)
    }

    private func setupUI() {
        applyFloatingButtonShadow()
        containerView.clipsToBounds = true

        icon.contentMode = .scaleAspectFit
        label.font = UIFont.veryBigButtonFont
        label.textColor = UIColor.white
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
    }

    @objc private dynamic func didPressButton() {
        buttonTouchBlock?()
    }
}
