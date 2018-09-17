import LGComponents
import RxCocoa
import RxSwift

final class ShareScreenshotViewController: BaseViewController {
    
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
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
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
    
    private func setupLayout() {
        view.addSubviewsForAutoLayout([closeButton, screenshotImageView, messengerButton, whatsappButton, messagesButton, moreButton, subtitleLabel, titleLabel])
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
            
            messengerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.bigMargin),
            messengerButton.heightAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            messengerButton.widthAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            messengerButton.rightAnchor.constraint(equalTo: whatsappButton.leftAnchor, constant: -Metrics.margin),

            whatsappButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.bigMargin),
            whatsappButton.heightAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            whatsappButton.widthAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            whatsappButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -(view.frame.size.width / 2 + Metrics.margin / 2)),
            
            messagesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.bigMargin),
            messagesButton.heightAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            messagesButton.widthAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            messagesButton.leftAnchor.constraint(equalTo: whatsappButton.rightAnchor, constant: Metrics.margin),
            
            moreButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Metrics.bigMargin),
            moreButton.heightAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            moreButton.widthAnchor.constraint(equalToConstant: Layout.shareButtonSideSize),
            moreButton.leftAnchor.constraint(equalTo: messagesButton.rightAnchor, constant: Metrics.margin),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: messengerButton.topAnchor, constant: -Metrics.bigMargin),
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
    
    
    // MARK: - UI Actions
    
    @objc private func closeButtonAction() {
        viewModel.close()
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
