final class LoadingViewController: UIViewController {
    
    private let loadingView = ActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviewForAutoLayout(loadingView)
        constraintViewToSafeRootView(loadingView)
    }
}


