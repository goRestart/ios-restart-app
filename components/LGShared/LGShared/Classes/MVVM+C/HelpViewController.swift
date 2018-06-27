import WebKit

public class HelpViewController: BaseViewController {
    private let webView = WKWebView()
    private var viewModel: HelpViewModel


    // MARK: - Lifecycle
    
    required public init(viewModel: HelpViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        automaticallyAdjustsScrollViewInsets = false
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.addToViewController(self, inView: self.view)

        // Navigation Bar
        setNavBarTitle(R.Strings.helpTitle)

        if let url = viewModel.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        setupAccessibilityIds()
    }
    
    
    // MARK: - Private methods

    private func setupAccessibilityIds() {
        webView.set(accessibility: Accessibility.helpWebView)
    }
}
