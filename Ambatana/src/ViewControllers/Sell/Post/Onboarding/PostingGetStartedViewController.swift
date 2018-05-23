import RxSwift
import LGComponents

class PostingGetStartedViewController: BaseViewController {

    private struct PostingGetStartedMetrics {
        static let margin: CGFloat = 30
        static let avatarSize: CGFloat = 100
        static let buttonHeight: CGFloat = 60
        static let skipButtonHeight: CGFloat = 64
        static let skipButtonWidth: CGFloat = 80
    }

    private let viewModel: PostingGetStartedViewModel

    private let avatarView = UIImageView()
    private let shadowView = UIView()
    private let textContainerView = UIView()
    private let welcomeLabel = UILabel()
    private let infoLabel = UILabel()
    private let getStartedButton = LetgoButton(type: .custom)
    private let discardLabel = UILabel()
    private let skipButton = UIButton(type: .custom)

    let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    
    init(viewModel: PostingGetStartedViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarView.setRoundedCorners()

        shadowView.setRoundedCorners()
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.masksToBounds = false

        getStartedButton.setStyle(.primary(fontSize: .big))
    }
    
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.white

        avatarView.layer.borderWidth = 5
        avatarView.layer.borderColor = UIColor.white.cgColor
        avatarView.isHidden = true

        shadowView.layer.borderWidth = 1
        shadowView.backgroundColor = UIColor.white
        shadowView.isHidden = true

        welcomeLabel.font = UIFont.postingFlowSelectableItem
        welcomeLabel.textColor = UIColor.darkGrayText
        welcomeLabel.text = viewModel.welcomeText
        welcomeLabel.numberOfLines = 0

        infoLabel.font = UIFont.postingFlowBody
        infoLabel.textColor = UIColor.blackText
        infoLabel.text = viewModel.infoText
        infoLabel.numberOfLines = 0

        getStartedButton.setTitle(viewModel.buttonText, for: .normal)
        getStartedButton.setImage(viewModel.buttonIcon, for: .normal)
        getStartedButton.imageView?.contentMode = .scaleAspectFit
        getStartedButton.imageView?.tintColor = UIColor.primaryColor.withAlphaComponent(0.5)
        getStartedButton.imageEdgeInsets = UIEdgeInsets(top: Metrics.bigMargin, left: -Metrics.shortMargin, bottom: Metrics.bigMargin, right: 0)
        getStartedButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.shortMargin, bottom: 0, right: 0)

        discardLabel.font = UIFont.smallBodyFont
        discardLabel.textColor = UIColor.grayText
        discardLabel.text = viewModel.discardText
        discardLabel.numberOfLines = 0
        discardLabel.textAlignment = .center
        
        if viewModel.shouldShowSkipButton {
            skipButton.setTitle(R.Strings.postingButtonSkip, for: .normal)
            skipButton.titleLabel?.font = UIFont.systemSemiBoldFont(size: 17)
            skipButton.titleLabel?.textAlignment = .center
            skipButton.titleLabel?.minimumScaleFactor = 0.5
            skipButton.titleLabel?.adjustsFontSizeToFitWidth = true
            skipButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    private func setupConstraints() {

        let textSubviews = [welcomeLabel, infoLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: textSubviews)
        textContainerView.addSubviews(textSubviews)

        welcomeLabel.layout(with: textContainerView)
            .left()
            .right()
            .top()
        welcomeLabel.layout(with: infoLabel).above(by: -Metrics.bigMargin)

        infoLabel.layout(with: textContainerView)
            .left()
            .right()
            .bottom()

        let subviews = [shadowView, avatarView, textContainerView, getStartedButton, discardLabel]
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        view.addSubviews(subviews)

        avatarView.layout()
            .width(PostingGetStartedMetrics.avatarSize)
            .height(PostingGetStartedMetrics.avatarSize)
        avatarView.layout(with: view).left(by: PostingGetStartedMetrics.margin)
        avatarView.layout(with: textContainerView).above(by: -PostingGetStartedMetrics.margin)

        shadowView.layout()
            .width(PostingGetStartedMetrics.avatarSize)
            .height(PostingGetStartedMetrics.avatarSize)
        shadowView.layout(with: avatarView).center()

        textContainerView.layout(with: view)
            .center()
            .left(by: PostingGetStartedMetrics.margin)
            .right(by: -PostingGetStartedMetrics.margin)

        getStartedButton.layout().height(PostingGetStartedMetrics.buttonHeight)
        getStartedButton.layout(with: view)
            .centerX()
            .left(by: PostingGetStartedMetrics.margin)
            .right(by: -PostingGetStartedMetrics.margin)
        getStartedButton.layout(with: discardLabel).above(by: -PostingGetStartedMetrics.margin)

        discardLabel.layout(with: view)
            .centerX()
            .left(by: PostingGetStartedMetrics.margin)
            .right(by: -PostingGetStartedMetrics.margin)
            .bottom(by: -PostingGetStartedMetrics.margin)
        
        if viewModel.shouldShowSkipButton {
            view.addSubviewForAutoLayout(skipButton)
            skipButton.layout(with: view).top().trailing()
            skipButton.layout()
                .height(PostingGetStartedMetrics.skipButtonHeight)
                .width(PostingGetStartedMetrics.skipButtonWidth)
        }
    }

    private func setupRx() {
        viewModel.userAvatarImage.asObservable().bind { [weak self] image in
            guard let image = image else { return }
                self?.avatarView.image = image
                self?.avatarView.isHidden = false
                self?.shadowView.isHidden = false
            }.disposed(by: disposeBag)

        getStartedButton.rx.tap.bind { [weak self] in
            self?.nextAction()
        }.disposed(by: disposeBag)
        
        skipButton.rx.tap.bind { [weak self] in
            self?.skipAction()
        }.disposed(by: disposeBag)
    }

    private func nextAction() {
        viewModel.nextAction()
    }
    
    private func skipAction() {
        viewModel.skipAction()
    }
}
