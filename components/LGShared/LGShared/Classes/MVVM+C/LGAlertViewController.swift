import UIKit
import RxSwift
import RxCocoa

public enum AlertType {
    case plainAlert
    case plainAlertOld
    case iconAlert(icon: UIImage?)

    public var titleTopSeparation: CGFloat {
        switch self {
        case .plainAlertOld, .plainAlert:
            return 20
        case let .iconAlert(icon):
            return icon == nil ? 20 : 75
        }
    }

    public var contentTopSeparation: CGFloat {
        switch self {
        case .plainAlertOld, .plainAlert:
            return 0
        case let .iconAlert(icon):
            return icon == nil ? 0 : 55
        }
    }

    public var containerCenterYOffset: CGFloat {
        return -contentTopSeparation/2
    }
}

public enum AlertButtonsLayout {
    case horizontal
    case vertical
    case emojis
    
    public var buttonsHeight: CGFloat {
        switch self {
        case .horizontal, .vertical:
            return LGUIKitConstants.mediumButtonHeight
        case .emojis:
            return 60
        }
    }
    
    public var buttonsMargin: CGFloat {
        switch self {
        case .horizontal, .vertical:
            return 10
        case .emojis:
            return 50
        }
    }
    
    public var topButtonMargin: CGFloat {
        switch self {
        case .horizontal:
            return 0
        case .emojis, .vertical:
            return 25
        }
    }
}

final public class LGAlertViewController: UIViewController {


    private struct Layout {
        static let buttonsContainerTopSeparation: CGFloat = 20
        static let iconHeight: CGFloat = 110
        static let iconWidth: CGFloat = 110
        static let titleTopMargin: CGFloat = 75
        static let alertCornerRadius: CGFloat = 15
        static let buttonContainerHeight: CGFloat = 44
        static let defaultWidth: CGFloat = 270
        static let contentTopMargin: CGFloat = 55
    }

    private let alertContainerView = UILayoutGuide()

    private let alertContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Layout.alertCornerRadius
        view.clipsToBounds = true
        return view
    }()

    private let alertIcon: UIImageView = {
        let image = UIImageView()
        return image
    }()

    private let alertTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let alertTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let buttonsContainer = UIView()
    private var alertContainerWidthConstraint: NSLayoutConstraint?
    private var buttonsContainerViewTopSeparationConstraint: NSLayoutConstraint?

    private let alertType: AlertType
    private let buttonsLayout: AlertButtonsLayout

    private let alertTitle: String?
    private let alertText: String?
    private let alertActions: [UIAction]?
    private let dismissAction: (() -> ())?

    private let disposeBag = DisposeBag()
    
    public var simulatePushTransitionOnPresent: Bool = false
    public var simulatePushTransitionOnDismiss: Bool = false
    
    public var alertWidth: CGFloat = Layout.defaultWidth {
        didSet {
            view.setNeedsLayout()
        }
    }

    // MARK: - Lifecycle

    public init?(title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout = .horizontal,
          actions: [UIAction]?, dismissAction: (() -> ())? = nil) {
        self.alertTitle = title
        self.alertText = text
        self.alertActions = actions
        self.alertType = alertType
        self.buttonsLayout = buttonsLayout
        self.dismissAction = dismissAction
        super.init(nibName: nil, bundle: nil)
        setupForModalWithNonOpaqueBackground()
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupConstraints()
        setupUI()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        alertContainerWidthConstraint?.constant = alertWidth
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if simulatePushTransitionOnPresent {
            view.alpha = 0
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.alpha = 1
            }
            
            let animation = CATransition()
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromRight
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            alertContentView.layer.add(animation, forKey: kCATransition)
        }
    }


    // MARK: - Private Methods

    private func setupUI() {

        switch alertType {
        case .plainAlert:
            alertIcon.image = nil
            alertTitleLabel.font = UIFont.systemBoldFont(size: 23)
            alertTitleLabel.textAlignment = .left
            alertTextLabel.textAlignment = .left
        case .plainAlertOld:
            alertIcon.image = nil
            alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        case let .iconAlert(icon):
            alertIcon.image = icon
            alertTitleLabel.font = UIFont.systemMediumFont(size: 17)
        }
        alertTextLabel.font = UIFont.systemRegularFont(size: 15)
        alertTitleLabel.text = alertTitle
        alertTextLabel.text = alertText

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
        view.addGestureRecognizer(tapRecognizer)

        alertContentView.cornerRadius = LGUIKitConstants.bigCornerRadius

        setupButtons(alertActions)
    }

    private func setupConstraints() {
        view.addLayoutGuide(alertContainerView)
        view.addSubviewsForAutoLayout([alertContentView, alertIcon])
        alertContentView.addSubviewsForAutoLayout([alertTitleLabel, alertTextLabel, buttonsContainer])

        var constraints: [NSLayoutConstraint] = [
            alertContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertContentView.leftAnchor.constraint(equalTo: alertContainerView.leftAnchor),
            alertContentView.rightAnchor.constraint(equalTo: alertContainerView.rightAnchor),
            alertContentView.bottomAnchor.constraint(equalTo: alertContainerView.bottomAnchor),
            alertIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertIcon.centerYAnchor.constraint(equalTo: alertContentView.topAnchor),
            alertIcon.heightAnchor.constraint(equalToConstant: Layout.iconHeight),
            alertIcon.widthAnchor.constraint(equalToConstant: Layout.iconWidth),
            alertTitleLabel.leftAnchor.constraint(equalTo: alertContentView.leftAnchor, constant: Metrics.veryBigMargin),
            alertTitleLabel.rightAnchor.constraint(equalTo: alertContentView.rightAnchor, constant: -Metrics.veryBigMargin),
            alertTextLabel.topAnchor.constraint(equalTo: alertTitleLabel.bottomAnchor, constant: Metrics.margin),
            alertTextLabel.leftAnchor.constraint(equalTo: alertContentView.leftAnchor, constant: Metrics.veryBigMargin),
            alertTextLabel.rightAnchor.constraint(equalTo: alertContentView.rightAnchor, constant: -Metrics.veryBigMargin),
            buttonsContainer.leftAnchor.constraint(equalTo: alertContentView.leftAnchor, constant: Metrics.veryBigMargin),
            buttonsContainer.rightAnchor.constraint(equalTo: alertContentView.rightAnchor, constant: -Metrics.veryBigMargin),
            buttonsContainer.bottomAnchor.constraint(equalTo: alertContentView.bottomAnchor, constant: -Metrics.veryBigMargin),
            buttonsContainer.heightAnchor.constraint(equalToConstant: Layout.buttonContainerHeight),
            alertContentView.topAnchor.constraint(equalTo: alertContainerView.topAnchor, constant: alertType.contentTopSeparation),
            alertTitleLabel.topAnchor.constraint(equalTo: alertIcon.centerYAnchor, constant: alertType.titleTopSeparation),
            alertContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: alertType.containerCenterYOffset),
        ]

        let buttonsTop = buttonsContainer.topAnchor.constraint(equalTo: alertTextLabel.bottomAnchor, constant: Metrics.veryBigMargin)
        buttonsContainerViewTopSeparationConstraint = buttonsTop

        let widthConstraint = alertContainerView.widthAnchor.constraint(equalToConstant: Layout.defaultWidth)
        alertContainerWidthConstraint = widthConstraint

        constraints.append(contentsOf: [buttonsTop, widthConstraint])
        NSLayoutConstraint.activate(constraints)
    }

    private func setupButtons(_ actions: [UIAction]?) {

        buttonsContainer.subviews.forEach { $0.removeFromSuperview() }

        // Actions must have interface == .button
        guard let buttonActions = actions else { return }
        // No actions -> No buttons
        guard buttonActions.count > 0 else {
            buttonsContainerViewTopSeparationConstraint?.constant = 0
            return
        }
        buttonsContainerViewTopSeparationConstraint?.constant = Layout.buttonsContainerTopSeparation

        switch buttonsLayout {
        case .horizontal:
            buildButtonsHorizontally(buttonActions)
        case .vertical:
            buildButtonsVertically(buttonActions)
        case .emojis:
            buildEmojiButtons(actions: buttonActions)
        }
    }

    private func buildEmojiButtons(actions: [UIAction]) {
        
        let centeredContainer = UIView()
        centeredContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(centeredContainer)
        centeredContainer.layout(with: buttonsContainer)
            .top()
            .bottom()
            .centerX()
        var previous: UIView? = nil
        for action in actions {
            let button = LetgoButton()
            button.imageView?.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false
            centeredContainer.addSubview(button)
            button.layout(with: centeredContainer)
                .top(by: AlertButtonsLayout.emojis.topButtonMargin)
                .bottom()
            button.layout()
                .width(AlertButtonsLayout.emojis.buttonsHeight)
                .widthProportionalToHeight()
            if let previous = previous {
                button.layout(with: previous)
                    .left(to: .right, by: AlertButtonsLayout.emojis.buttonsMargin)
            } else {
                button.layout(with: centeredContainer)
                    .left()
            }
            previous = button
            styleButton(button, action: action)
        }
        if let lastBtn = previous {
            lastBtn.layout(with: centeredContainer).right()
        }
        _ = buttonsContainer.addTopBorderWithWidth(1, color: UIColor.gray)
    }
    
    private func buildButtonsHorizontally(_ buttonActions: [UIAction]) {
        let widthMultiplier: CGFloat = 1 / CGFloat(buttonActions.count)
        let widthConstant: CGFloat = buttonActions.count == 1 ? 0 : -(AlertButtonsLayout.horizontal.buttonsMargin/2)
        var previous: UIView? = nil
        for action in buttonActions {
            let button = LetgoButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(button)
            button.layout(with: buttonsContainer)
                .top(by: AlertButtonsLayout.horizontal.topButtonMargin)
                .bottom()
                .width(widthConstant, multiplier: widthMultiplier)
            button.layout().height(AlertButtonsLayout.horizontal.buttonsHeight)
            if let previous = previous {
                button.layout(with: previous).left(to: .right, by: AlertButtonsLayout.horizontal.buttonsMargin)
            } else {
                button.layout(with: buttonsContainer).left()
            }
            previous = button
            styleButton(button, action: action)
        }
        if let lastBtn = previous {
            lastBtn.layout(with: buttonsContainer).right()
        }
    }

    private func buildButtonsVertically(_ buttonActions: [UIAction]) {
        var previous: UIView? = nil
        for action in buttonActions {
            let button = LetgoButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(button)
            button.layout(with: buttonsContainer).fillHorizontal()
            button.layout().height(AlertButtonsLayout.vertical.buttonsHeight)
            if let previous = previous {
                button.layout(with: previous).top(to: .bottom, by: AlertButtonsLayout.vertical.buttonsMargin)
            } else {
                button.layout(with: buttonsContainer).top(by: AlertButtonsLayout.vertical.topButtonMargin)
            }
            previous = button
            styleButton(button, action: action)
        }
        if let lastBtn = previous {
            lastBtn.layout(with: buttonsContainer).bottom()
        }
        _ = buttonsContainer.addTopBorderWithWidth(1, color: UIColor.gray)
    }

    private func styleButton(_ button: LetgoButton, action: UIAction) {
        switch action.interface {
        case let .image(image, _):
            button.setImage(image, for: .normal)
        case .button, .styledText, .text, .textImage:
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitle(action.text, for: .normal)
            button.set(accessibility: action.accessibility)
            button.setStyle(action.buttonStyle ?? .primary(fontSize: .medium))
        }
        
        button.rx.tap.bind { [weak self] in
            self?.dismissAlert(pushTransition: true) {
                action.action()
            }
        }.disposed(by: disposeBag)
    }

    @objc private func tapOutside() {
        dismissAlert(pushTransition: false) { [weak self] in
            self?.dismissAction?()
        }
    }

    private func dismissAlert(pushTransition: Bool, completion: (() -> Void)?) {
        if pushTransition && simulatePushTransitionOnDismiss {
            let animation = CATransition()
            animation.type = kCATransitionPush
            animation.subtype = kCATransitionFromRight
            animation.duration = 0.2
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            alertContentView.layer.add(animation, forKey: kCATransition)
            
            // modalTransitionStyle = .crossDissolve will add a layer animation on dismiss and you will see
            // twice the alertContentView, 1 from our push animation and 2 from the crossDisolve animation.
            // we set the alpha to 0 to prevent any weirdness
            alertContentView.alpha = 0
            
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.view.alpha = 0 // to prevent flickering from one controller to another
            }, completion: { (completed) in
                self.dismiss(animated: false, completion: completion)
            })
        } else {
            dismiss(animated: true, completion: completion)
        }
    }
}
