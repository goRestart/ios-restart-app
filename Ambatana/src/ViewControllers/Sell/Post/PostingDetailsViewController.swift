import Foundation
import LGCoreKit
import RxSwift
import LGComponents

class PostingDetailsViewController: KeyboardViewController, LGSearchMapViewControllerModelDelegate, PostingDetailsViewModelDelegate {
    
    fileprivate static let titleHeight: CGFloat = 60
    fileprivate static let skipButtonMinimumWidth: CGFloat = 100
    static let skipButtonHeight: CGFloat = 44
    
    private let titleLabel: UILabel = UILabel()
    private let contentView: UIView = UIView()
    private var infoView: PostingViewConfigurable?
    private let buttonNext = LetgoButton()
    private var buttonNextBottomMargin = NSLayoutConstraint()
    
    private let viewModel: PostingDetailsViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: PostingDetailsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil, swipeBackGestureEnabled: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupConstraints()
        setupUI()
        setupRx()
        infoView?.setupView(viewModel: viewModel)
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupNavigationBar()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.clipsToBounds = true
        
        titleLabel.text = viewModel.title
        buttonNext.setTitle(viewModel.buttonTitle, for: .normal)
        
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        titleLabel.font = UIFont.postingFlowHeadline
        titleLabel.textColor = UIColor.white
        
        buttonNext.setStyle(viewModel.doneButtonStyle)
        
        buttonNext.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
    }
    
    func setupRx() {
        viewModel.sizeListingObservable.bind { [weak self] size in
            guard let strongSelf = self else { return }
            strongSelf.buttonNext.setStyle(strongSelf.viewModel.doneButtonStyle)
            strongSelf.buttonNext.setTitle(strongSelf.viewModel.buttonTitle, for: .normal)
        }.disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController as? SellNavigationController else { return }
        let currentStep = navigationController.currentStep
        setNavBarBackgroundStyle(.transparent(substyle: .dark))
        
        let backImage = R.Asset.IconsButtons.navbarBackWhiteShadow.image
        let closeImage = R.Asset.IconsButtons.icPostClose.image
        
        if currentStep == 1 || viewModel.isSummaryStep {
            let closeButton = UIBarButtonItem(image: closeImage , style: UIBarButtonItemStyle.plain,
                                              target: self, action: #selector(PostingDetailsViewController.closeButtonPressed))
            closeButton.setBackgroundVerticalPositionAdjustment(5, for: .default)
            self.navigationItem.leftBarButtonItem = closeButton
        } else {
            let backButton = UIBarButtonItem(image: backImage , style: UIBarButtonItemStyle.plain,
                                              target: self, action: #selector(PostingDetailsViewController.popBackViewController))
            backButton.setBackgroundVerticalPositionAdjustment(5, for: .default)
            self.navigationItem.leftBarButtonItem = backButton
        }
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        buttonNext.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        titleLabel.layout(with: view).fillHorizontal(by: Metrics.bigMargin)
        let topAnchor: NSLayoutYAxisAnchor
        let constant: CGFloat
        if #available(iOS 11, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
            constant = Metrics.bigMargin
        } else {
            topAnchor = view.topAnchor
            constant = PostingDetailsViewController.titleHeight
        }
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: constant).isActive = true
        
        view.addSubview(contentView)
        contentView.layout(with: titleLabel).below(by: Metrics.bigMargin)
        contentView.layout(with: view).fillHorizontal(by: Metrics.veryShortMargin)
        contentView.layout(with: view).bottom()
        
        
        infoView = viewModel.makeContentView(viewControllerDelegate: self)
        infoView?.setupContainerView(view: contentView)
        
        view.addSubview(buttonNext)
        buttonNext.layout(with: view).bottom(by: -Metrics.margin)
        buttonNext.layout().height(PostingDetailsViewController.skipButtonHeight)
        buttonNext.layout().width(PostingDetailsViewController.skipButtonMinimumWidth, relatedBy: .greaterThanOrEqual)
        if viewModel.shouldFollowKeyboard {
            buttonNext.layout(with: keyboardView).bottom(to: .top, by: -Metrics.bigMargin)
        } else {
            buttonNext.layout(with: view).bottom(by: -Metrics.bigMargin)
        }
        if viewModel.buttonFullWidth {
            buttonNext.layout(with: keyboardView).left(by: Metrics.bigMargin)
        }
        buttonNext.layout(with: view).right(by: -Metrics.bigMargin)
    }
    
    
    // MARK: - UIActions
    
    @objc func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    @objc func nextButtonPressed() {
        viewModel.nextbuttonPressed()
    }
}

