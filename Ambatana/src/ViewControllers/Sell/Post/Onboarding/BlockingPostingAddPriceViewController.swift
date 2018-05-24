import LGComponents

final class BlockingPostingAddPriceViewController: KeyboardViewController, BlockingPostingStepHeaderViewDelegate {
    
    private static let doneButtonHeight: CGFloat = 44
    private static let doneButtonWidth: CGFloat = 100
    private static let addDetailPriceViewTopMargin: CGFloat = 30
    
    private let doneButton = LetgoButton()
    private var addDetailPriceView: PostingViewConfigurable?
    private let contentView = UIView()
    
    private let headerView = BlockingPostingStepHeaderView()
    private let viewModel: BlockingPostingAddPriceViewModel
    
    
    // MARK: - Lifecycle
    
    init(viewModel: BlockingPostingAddPriceViewModel) {
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
    }

    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    // MARK: - UI
    
    private func setupUI() {     
        view.backgroundColor = .clear
        
        doneButton.setTitle(R.Strings.productPostDone, for: .normal)
        doneButton.setStyle(.primary(fontSize: .medium))
        doneButton.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        
        headerView.delegate = self

        let addDetailPriceView = viewModel.makePriceView()
        addDetailPriceView.setupContainerView(view: contentView)
        addDetailPriceView.updatePriceTextFieldToFirstResponder()
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([headerView, doneButton, contentView])
        
        headerView.layout(with: view)
            .fillHorizontal()
            .top()
        headerView.layout().height(BlockingPostingStepHeaderView.height)
         headerView.updateWith(stepNumber: BlockingPostingAddPriceViewModel.headerStep.rawValue, title: BlockingPostingAddPriceViewModel.headerStep.title)
        
        contentView.layout(with: headerView).top(to: .bottom)
        contentView.layout(with: view).fillHorizontal(by: Metrics.veryShortMargin)
        contentView.layout(with: keyboardView).bottom(to: .top, by: -(BlockingPostingAddPriceViewController.doneButtonHeight+Metrics.bigMargin*2))
        
        doneButton.layout(with: view).bottom(by: -Metrics.margin)
        doneButton.layout().height(BlockingPostingAddPriceViewController.doneButtonHeight)
        doneButton.layout().width(BlockingPostingAddPriceViewController.doneButtonWidth)
        doneButton.layout(with: keyboardView).bottom(to: .top, by: -Metrics.bigMargin)
        doneButton.layout(with: view).right(by: -Metrics.bigMargin)
    }
    
    
    // MARK: - UI Actions
    
    @objc func doneButtonAction() {
        viewModel.doneButtonAction()
    }
    
    
    // MARK: - BlockingPostingStepHeaderViewDelegate
    
    func didTapStepHeaderView() {
        view.endEditing(true)
    }
}
