import Foundation
import RxSwift
import LGComponents

class BlockingPostingQueuedRequestsViewController: BaseViewController, BlockingPostingLoadingViewDelegate {
    
    private static let closeButtonHeight: CGFloat = 52
    
    private let loadingView = BlockingPostingLoadingView()
    private let closeButton = UIButton()

    private let viewModel: BlockingPostingQueuedRequestsViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(viewModel: BlockingPostingQueuedRequestsViewModel) {
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
        viewModel.startQueuedRequests()
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        if let state = viewModel.queueState.value, state.isAnimated {
            loadingView.updateWith(message: state.message, isError: state.isError, isAnimated: state.isAnimated)
        }
    }
    
    private func setupRx() {
        viewModel.queueState.asObservable()
            .bind { [weak self] state in
                guard let state = state else { return }
                self?.closeButton.isHidden = !state.isError
                self?.loadingView.updateWith(message: state.message, isError: state.isError, isAnimated: state.isAnimated)
            }.disposed(by: disposeBag)
    }
    
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        closeButton.setImage(R.Asset.IconsButtons.icPostClose.image, for: .normal)
        
        loadingView.delegate = self
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([closeButton, loadingView])
        
        closeButton.layout(with: view)
            .top(by: toastView?.height ?? 0)
            .left()
        closeButton.layout()
            .height(BlockingPostingQueuedRequestsViewController.closeButtonHeight)
            .widthProportionalToHeight()
        
        loadingView.layout(with: view)
            .fillHorizontal()
            .bottom()
        loadingView.layout(with: closeButton).top(to: .bottom)
    }
    
    
    // MARK: - UI Actions
    
    @objc func closeButtonAction() {
        viewModel.closeButtonAction()
    }
    
    
    // MARK: - BlockingPostingLoadingViewDelegate
    
    func didPressRetryButton() {
        viewModel.startQueuedRequests()
    }
}

