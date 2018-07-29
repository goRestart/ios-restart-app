import LGComponents

final class ErrorViewController: UIViewController {
    
    enum Style {
        case feed, user
    }
    
    enum ErrorViewLayout {
        static let borderWidth: CGFloat = 0.5
        static let cornerRadius: CGFloat = 4
    }
    
    private let errorView = ErrorView()
    private let style: Style
    private let viewModel: LGEmptyViewModel
    
    static let errorButtonHeight: CGFloat = 50
    
    var retryHandler: () -> Void = {}
    
    // MARK:- Life Cycle
    
    init(style: Style, viewModel: LGEmptyViewModel) {
        self.style = style
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviewForAutoLayout(errorView)
        addConstraints()
        setErrorViewStyle()
        setErrorState()
        setErrorButtonAction()
    }
    
    
    // MARK:- Private Methods

    private func addConstraints() {
        NSLayoutConstraint.activate([
            errorView.leftAnchor.constraint(equalTo: view.leftAnchor),
            errorView.rightAnchor.constraint(equalTo: view.rightAnchor),
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setErrorButtonAction() {
        errorView.actionButton.addTarget(self, action: #selector(errorButtonPressed), for: .touchUpInside)
    }
    
    private func setErrorViewStyle() {
        
        let bgColor: UIColor?
        let borderColor: UIColor?
        let containerColor: UIColor?
        
        switch style {
        case .user:
            bgColor = .white
            borderColor = .clear
            containerColor = .white
        case .feed:
            bgColor = UIColor(patternImage: R.Asset.BackgroundsAndImages.patternWhite.image)
            borderColor = UIColor.lineGray
            containerColor = .white
        }

        errorView.backgroundColor = bgColor
        errorView.containerView.backgroundColor = containerColor
        errorView.containerView.layer.borderColor = borderColor?.cgColor
        errorView.containerView.layer.borderWidth = borderColor != nil ? ErrorViewLayout.borderWidth : 0
        errorView.containerView.cornerRadius = ErrorViewLayout.cornerRadius
    }
    
    private func setErrorState() {
        errorView.setImage(viewModel.icon)
        errorView.imageHeight?.constant = viewModel.iconHeight
        errorView.setTitle(viewModel.title)
        errorView.setBody(viewModel.body)
        errorView.actionButton.setTitle(viewModel.buttonTitle, for: .normal)
        errorView.actionHeight?.constant = viewModel.hasAction ? ErrorViewController.errorButtonHeight : 0
        errorView.setNeedsLayout()
    }
    
    @objc func errorButtonPressed() {
        retryHandler()
    }
}
