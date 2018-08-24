import Foundation
import LGCoreKit
import RxSwift
import LGComponents

final class PostingDetailsViewController: KeyboardViewController, LGSearchMapViewControllerModelDelegate, PostingDetailsViewModelDelegate {
    
    fileprivate static let titleHeight: CGFloat = 60
    fileprivate static let skipButtonMinimumWidth: CGFloat = 100
    fileprivate static let topScrollMax: CGFloat = 160
    static let skipButtonHeight: CGFloat = 44
    
    
    private let headerView = UIView()
    private let contentView: UIView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.postingFlowHeadline
        label.textColor = UIColor.white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.postingFlowHeadlineSubtitle
        label.textColor = UIColor.grayDark
        return label
    }()

    private var infoView: PostingViewConfigurable?
    private let buttonNext = LetgoButton()
    private var buttonNextBottomMargin = NSLayoutConstraint()
    private var topHeaderConstraint: NSLayoutConstraint?
    private var topHeaderInitialDistance: CGFloat = 0
    
    
    // This view will match the bounds of the next button and absorb the touch to stop the tableView
    // from taking the touch when the next button is disabled
    private let buttonNextUnderView = UIView()
    
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
        setupUI()
        setupConstraints()
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
        view.backgroundColor = .clear
        
        if viewModel.showsNextButton {
            view.addSubviewsForAutoLayout([headerView, contentView, buttonNextUnderView, buttonNext])
            buttonNext.setTitle(viewModel.buttonTitle, for: .normal)
            buttonNext.setStyle(viewModel.doneButtonStyle)
            buttonNext.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        } else {
            view.addSubviewsForAutoLayout([headerView, contentView])
        }
        
        headerView.addSubviewsForAutoLayout([titleLabel, subtitleLabel])

        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
       
        contentView.backgroundColor = .clear
    }
    
    func setupRx() {
        viewModel.sizeListingObservable.bind { [weak self] size in
            guard let strongSelf = self else { return }
            strongSelf.buttonNext.setStyle(strongSelf.viewModel.doneButtonStyle)
            strongSelf.buttonNext.setTitle(strongSelf.viewModel.buttonTitle, for: .normal)
        }.disposed(by: disposeBag)
        
        viewModel.nextButtonEnabled.asObservable().bind { [weak self] (enabled) in
            guard let strongSelf = self else { return }
            strongSelf.buttonNext.isEnabled = enabled
        }.disposed(by: disposeBag)
        
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController as? SellNavigationController else { return }
        setNavBarBackgroundStyle(.transparent(substyle: .dark))
        
        let backImage = R.Asset.IconsButtons.navbarBackWhiteShadow.image
        let closeImage = R.Asset.IconsButtons.icPostClose.image
        
        if viewModel.isSummaryStep {
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

        headerView.layout(with: view).fillHorizontal()
        
        titleLabel.layout(with: headerView).top().fillHorizontal(by: Metrics.bigMargin)
        subtitleLabel.layout(with: headerView).bottom().fillHorizontal(by: Metrics.bigMargin)
        
        subtitleLabel.layout(with: titleLabel).below(by: Metrics.shortMargin)
        
        if #available(iOS 11, *) {
            topHeaderInitialDistance =  Metrics.bigMargin
        } else {
            topHeaderInitialDistance =  PostingDetailsViewController.titleHeight
        }
        topHeaderConstraint = headerView.topAnchor.constraint(equalTo: safeTopAnchor, constant: topHeaderInitialDistance)
        topHeaderConstraint?.isActive = true
        
        contentView.layout(with: headerView).below(by: Metrics.bigMargin)
        contentView.layout(with: view).fillHorizontal(by: Metrics.veryShortMargin)
        contentView.layout(with: view).bottom()
        
        
        infoView = viewModel.makeContentView(viewControllerDelegate: self)
        infoView?.setupContainerView(view: contentView)

        if viewModel.showsNextButton {
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
            
            buttonNextUnderView.layout(with: buttonNext)
                .centerX()
                .centerY()
            
            buttonNextUnderView.layout(with: buttonNext).fill()
        }

    }
    
    func detailViewScrolled(contentOffsetY: CGFloat) {
        if contentOffsetY <= 1 {
            navigationController?.setNavigationBarHidden(false, animated: true)
        } else if contentOffsetY < topHeaderInitialDistance {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        topHeaderConstraint?.constant = max(topHeaderInitialDistance - contentOffsetY,
                                            topHeaderInitialDistance - PostingDetailsViewController.topScrollMax)
    }
    
    func detailViewScrollToTop() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        topHeaderConstraint?.constant = topHeaderInitialDistance - PostingDetailsViewController.topScrollMax
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - UIActions
    
    @objc func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    @objc func nextButtonPressed() {
        viewModel.nextbuttonPressed()
    }
}

