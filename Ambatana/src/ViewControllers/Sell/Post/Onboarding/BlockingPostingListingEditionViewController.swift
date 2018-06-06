import LGCoreKit
import RxSwift
import LGComponents

final class BlockingPostingListingEditionViewController: BaseViewController, BlockingPostingLoadingViewDelegate {
    
    private static let closeButtonHeight: CGFloat = 52
    
    private let loadingView = BlockingPostingLoadingView()
    private let closeButton = UIButton()
    
    private let viewModel: BlockingPostingListingEditionViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: BlockingPostingListingEditionViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupUI()
        setupRx()
        viewModel.updateListing()
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        if let state = viewModel.state.value, state.isAnimated {
            loadingView.updateWith(message: state.message, isError: state.isError, isAnimated: state.isAnimated)
        }
    }
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(BlockingPostingListingEditionViewController.closeButtonAction), for: .touchUpInside)
        closeButton.setImage(R.Asset.IconsButtons.icPostClose.image, for: .normal)
        
        loadingView.delegate = self
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([closeButton, loadingView])
        
        closeButton.layout(with: view)
            .top(by: toastView?.height ?? 0)
            .left()
        closeButton.layout()
            .height(BlockingPostingListingEditionViewController.closeButtonHeight)
            .widthProportionalToHeight()
        
        loadingView.layout(with: view)
            .fillHorizontal()
            .bottom()
        loadingView.layout(with: closeButton).top(to: .bottom)
    }
    
    private func setupRx() {
        viewModel.state.asObservable().distinctUntilChanged { (s1, s2) -> Bool in
            s1 == s2
        }.bind { [weak self] state in
            guard let state = state else { return }
            self?.closeButton.isHidden = !state.isError
            self?.loadingView.updateWith(message: state.message, isError: state.isError, isAnimated: state.isAnimated)
            if state == .success {
                self?.viewModel.openListingPosted()
            }
        }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI Actions
    
    @objc func closeButtonAction() {
        viewModel.closeButtonAction()
    }
    
    
    // MARK: - BlockingPostingLoadingViewDelegate
    
    func didPressRetryButton() {
        viewModel.updateListing()
    }
}
