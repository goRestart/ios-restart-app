import LGComponents
import RxCocoa
import RxSwift

final class ShareScreenshotViewController: BaseViewController {
    
    private let transitionAnimationDuration = 0.5
    
    enum Layout {
        static let closeButtonTopMargin: CGFloat = 20
        static let closeButtonLeadingMargin: CGFloat = 0
        static let closeButtonSize: CGFloat = 45
        static let screenshotImageViewTopMargin: CGFloat = 65
        static let screenshotImageViewBottomMargin: CGFloat = 35
        static let shareButtonSideSize: CGFloat = 50
        static let subtitleHeight: CGFloat = 26
        static let titleHeight: CGFloat = 42
    }
    
    var screenshotImageViewWidth: CGFloat {
        return view.width * 0.6
    }
    var screenshotImageViewHeight: CGFloat {
        return view.height * 0.6
    }
   
    private let viewModel: ShareScreenshotViewModel
    private let socialSharer: SocialSharer
    
    @objc fileprivate let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icCloseDark.image, for: .normal)
        return button
    }()
    private let screenshotImageView: UIImageView = {
        let screenshotImageView = UIImageView()
        screenshotImageView.contentMode = .scaleAspectFit
        screenshotImageView.clipsToBounds = true
        screenshotImageView.applyShadow(withOpacity: 0.5,
                                        radius: 10,
                                        color: UIColor.black.cgColor)
        screenshotImageView.layer.masksToBounds = false
        return screenshotImageView
    }()
    private let animatedScreenshotImageView = UIImageView()
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemBoldFont(size: 30)
        titleLabel.textAlignment = .center
        titleLabel.text = R.Strings.shareScreenshotTitle
        return titleLabel
    }()
    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.systemRegularFont(size: 18)
        subtitleLabel.textAlignment = .center
        subtitleLabel.text = R.Strings.shareScreenshotDescription
        return subtitleLabel
    }()
    private let buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalCentering
        buttonStackView.alignment = .center
        buttonStackView.spacing = Metrics.margin
        return buttonStackView
    }()
    private let messengerButton: UIButton = {
        let messengerButton = UIButton()
        messengerButton.setImage(R.Asset.IconsButtons.itemShareFbMessengerBig.image, for: .normal)
        return messengerButton
    }()
    private let whatsappButton: UIButton = {
        let whatsappButton = UIButton()
        whatsappButton.setImage(R.Asset.IconsButtons.itemShareWhatsappBig.image, for: .normal)
        return whatsappButton
    }()
    private let messagesButton: UIButton = {
        let messagesButton = UIButton()
        messagesButton.setImage(R.Asset.IconsButtons.itemShareSmsBig.image, for: .normal)
        return messagesButton
    }()
    private let moreButton: UIButton = {
        let moreButton = UIButton()
        moreButton.setImage(R.Asset.IconsButtons.itemShareMoreBig.image, for: .normal)
        return moreButton
    }()
    
    var hasOpeningTransitionPerformed: Bool = false
    
    
    // MARK: - Lifecycle
    
    convenience init(viewModel: ShareScreenshotViewModel) {
        self.init(viewModel: viewModel,
                  socialSharer: SocialSharer())
    }
    
    required init(viewModel: ShareScreenshotViewModel,
                  socialSharer: SocialSharer) {
        self.viewModel = viewModel
        self.socialSharer = socialSharer
        super.init(viewModel: viewModel, nibName: nil)
        
        animatedScreenshotImageView.image = viewModel.screenshotImage
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtonStackView()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasOpeningTransitionPerformed {
            performOpeningAnimation()
        }
    }
    
    // MARK: - UI
    
    private func setupUI() {
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        messengerButton.addTarget(self, action: #selector(messengerButtonAction), for: .touchUpInside)
        whatsappButton.addTarget(self, action: #selector(whatsappButtonAction), for: .touchUpInside)
        messagesButton.addTarget(self, action: #selector(messagesButtonAction), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        
        screenshotImageView.image = viewModel.screenshotImage
    }
    
    private func setupButtonStackView() {
        if SocialSharer.canShareIn(.whatsapp) {
            buttonStackView.addArrangedSubview(whatsappButton)
        }
        if SocialSharer.canShareIn(.fbMessenger) {
            buttonStackView.addArrangedSubview(messengerButton)
        }
        buttonStackView.addArrangedSubviews([messagesButton, moreButton])
    }
    
    private func setupLayout() {
        view.addSubviewsForAutoLayout([closeButton, screenshotImageView, buttonStackView, subtitleLabel, titleLabel])
        
        let constraints = [
            closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Layout.closeButtonLeadingMargin),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: Layout.closeButtonTopMargin),
            closeButton.heightAnchor.constraint(equalToConstant: Layout.closeButtonSize),
            closeButton.widthAnchor.constraint(equalToConstant: Layout.closeButtonSize),
            
            screenshotImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: Layout.screenshotImageViewTopMargin),
            screenshotImageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -Layout.screenshotImageViewBottomMargin),
            screenshotImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenshotImageView.heightAnchor.constraint(equalToConstant: screenshotImageViewHeight),
            screenshotImageView.widthAnchor.constraint(equalToConstant: screenshotImageViewWidth),
            
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.bigMargin),
            buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -Metrics.bigMargin),
            subtitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Metrics.margin),
            subtitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Metrics.margin),
            subtitleLabel.heightAnchor.constraint(equalToConstant: Layout.subtitleHeight),
            
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -Metrics.shortMargin),
            titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Metrics.margin),
            titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Metrics.margin),
            titleLabel.heightAnchor.constraint(equalToConstant: Layout.subtitleHeight),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    // MARK: - Opening and closing animations
    
    private func performOpeningAnimation() {
        let initialFrame = CGRect(x: 0,
                                  y: 0,
                                  width: view.width,
                                  height: view.height)
        let finalFrame = CGRect(x: view.frame.midX - screenshotImageViewWidth/2,
                                y: Layout.screenshotImageViewTopMargin,
                                width: screenshotImageViewWidth,
                                height: screenshotImageViewHeight)
        
        animatedScreenshotImageView.image = viewModel.screenshotImage
        
        view.addSubview(animatedScreenshotImageView)
        view.bringSubview(toFront: animatedScreenshotImageView)
        animatedScreenshotImageView.frame = initialFrame
        UIView.animate(withDuration: transitionAnimationDuration,
                       animations: { [weak self] in
                        self?.animatedScreenshotImageView.frame = finalFrame
            }, completion: { [weak self] _ in
                self?.animatedScreenshotImageView.alpha = 0
                self?.hasOpeningTransitionPerformed = true
        })
    }
    
    private func performClosingAnimation(completion: (() -> Void)?) {
        let initialFrame = CGRect(x: view.frame.midX - screenshotImageViewWidth/2,
                                  y: Layout.screenshotImageViewTopMargin,
                                  width: screenshotImageViewWidth,
                                  height: screenshotImageViewHeight)
        let finalFrame = CGRect(x: 0,
                                y: 0,
                                width: view.width,
                                height: view.height)
        
        animatedScreenshotImageView.image = viewModel.screenshotImage
        
        view.addSubview(animatedScreenshotImageView)
        view.bringSubview(toFront: animatedScreenshotImageView)
        animatedScreenshotImageView.frame = initialFrame
        self.animatedScreenshotImageView.alpha = 1
        UIView.animate(withDuration: transitionAnimationDuration,
                       animations: { [weak self] in
                        self?.animatedScreenshotImageView.frame = finalFrame
            }, completion: { _ in
                completion?()
        })
    }
    
    // MARK: - UI Actions
    
    @objc private func closeButtonAction() {
        performClosingAnimation { [weak self] in
            self?.viewModel.close()
        }
    }
    
    @objc private func messengerButtonAction(_ sender: AnyObject) {
        viewModel.buildShare(type: .fbMessenger, viewController: self)
    }
    
    @objc private func whatsappButtonAction(_ sender: AnyObject) {
        viewModel.buildShare(type: .whatsapp, viewController: self)
    }
    
    @objc private func messagesButtonAction(_ sender: AnyObject) {
        viewModel.buildShare(type: .sms, viewController: self)
    }
    
    @objc private func moreButtonAction(_ sender: AnyObject) {
        viewModel.buildShare(type: .native(restricted: true), viewController: self)
    }
}
