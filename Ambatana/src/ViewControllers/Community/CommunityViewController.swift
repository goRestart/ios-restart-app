import WebKit
import LGComponents
import RxSwift

final class CommunityViewController: BaseViewController {

    private let viewModel: CommunityViewModel
    private let webView = WKWebView()
    private let disposeBag = DisposeBag()

    init(viewModel: CommunityViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        hidesBottomBarWhenPushed = false
        floatingSellButtonHidden = false
        hasTabBar = true
        setupRx()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviewForAutoLayout(webView)
        setupNavBar()
        setupConstraints()
    }

    private func setupNavBar() {
        navigationController?.setNavigationBarHidden(!viewModel.showNavBar, animated: false)
        guard viewModel.showCloseButton else { return }
        setNavBarCloseButton(#selector(close))
    }

    private func setupConstraints() {
        var constraints = [
            webView.topAnchor.constraint(equalTo: safeTopAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]

        if tabBarController != nil {
            constraints.append(webView.bottomAnchor.constraint(equalTo: safeBottomAnchor))
        } else {
            constraints.append(webView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupRx() {
        viewModel
            .urlRequest
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()
            .drive(onNext: { [weak self] request in
                guard let request = request else { return }
                self?.loadWeb(with: request)
            })
            .disposed(by: disposeBag)
    }

    private func loadWeb(with request: URLRequest) {
        clearCookies() { [weak self] in
            self?.webView.load(request)
        }
    }

    private func clearCookies(completion: @escaping ()->Void) {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                                 for: records.filter { $0.displayName.contains("letgo.com") },
                                 completionHandler: completion)
        }
    }

    @objc private func close() {
        viewModel.didTapClose()
    }
}
