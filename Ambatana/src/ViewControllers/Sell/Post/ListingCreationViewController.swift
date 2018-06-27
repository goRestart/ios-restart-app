import Foundation
import LGCoreKit
import RxSwift
import LGComponents

class ListingCreationViewController: BaseViewController {
    
    struct LoadingMetrics {
        static var heightLoadingView: CGFloat = 100
        static var widthLoadingView: CGFloat = 100
    }
    
    private var loadingView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: LoadingMetrics.widthLoadingView, height: LoadingMetrics.widthLoadingView))
    private let viewModel: ListingCreationViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: ListingCreationViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupConstraints()
        setupUI()
        setupRx()
        viewModel.createListing()
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        guard let requestFinished = viewModel.didFinishRequest.value, !requestFinished else { return }
        loadingView.startAnimating()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.clipsToBounds = true
        view.backgroundColor = .clear
        loadingView.color = .white
        loadingView.startAnimating()
    }
    
    private func setupRx() {
        viewModel.didFinishRequest.asObservable().filter{ $0 == true }.bind { [weak self] finished in
            self?.viewModel.nextStep()
        }.disposed(by: disposeBag)
    }
    
    private func setupConstraints() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingView)
        
        loadingView.layout().height(LoadingMetrics.heightLoadingView).width(LoadingMetrics.widthLoadingView)
        loadingView.layout(with: view).centerY().centerX()
    }
}
