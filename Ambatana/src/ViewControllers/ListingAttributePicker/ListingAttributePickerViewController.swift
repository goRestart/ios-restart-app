import LGComponents

final class ListingAttributePickerViewController: KeyboardViewController {
    
    private struct Layout {
        static let doneButtonMinimumWidth: CGFloat = 100
        static let doneButtonHeight: CGFloat = 44
    }
    
    private let tableView: ListingAttributePickerTableView
    private let viewModel: ListingAttributePickerViewModel
    private let doneButton = LetgoButton()
    
    convenience init(viewModel: ListingAttributePickerViewModel) {
        switch viewModel.type {
        case .multiselect(let multiSelect):
            self.init(viewModel: multiSelect)
        case .singleSelect(let singleSelect):
            self.init(viewModel: singleSelect)
        }
    }
    
    private init(viewModel: ListingAttributeSingleSelectPickerViewModel) {
        self.viewModel = viewModel
        var selectedIndexes: [IndexPath] = []
        if let index = viewModel.selectedIndex {
            selectedIndexes.append(IndexPath(row: index, section: 0))
        }
        tableView = ListingAttributePickerTableView(values: viewModel.attributes,
                                                    selectedIndexes: selectedIndexes,
                                                    delegate: nil,
                                                    showsSearchBar: viewModel.canSearchAttributes,
                                                    allowsMultiselect: false,
                                                    allowsDeselect: viewModel.canDeselect)
        super.init(viewModel: viewModel, nibName: nil)
        self.tableView.delegate = self
        self.title = viewModel.title
    }
    
    private init(viewModel: ListingAttributeMultiselectPickerViewModel) {
        self.viewModel = viewModel
        let selectedIndexes = viewModel.selectedIndexes.map( { return IndexPath(row: $0, section: 0) } )
        tableView = ListingAttributePickerTableView(values: viewModel.attributes,
                                                    selectedIndexes: selectedIndexes,
                                                    delegate: nil,
                                                    showsSearchBar: viewModel.canSearchAttributes,
                                                    allowsMultiselect: true,
                                                    allowsDeselect: true)
        super.init(viewModel: viewModel, nibName: nil)
        self.tableView.delegate = self
        self.title = viewModel.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
    }
}

private extension ListingAttributePickerViewController {
    
    func setupViews() {
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        
        if viewModel.showsDoneButton {
            doneButton.setStyle(viewModel.doneButtonStyle)
            doneButton.setTitle(viewModel.doneButtonTitle, for: .normal)
            doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
            hideDoneButton()
        }
    }
    
    func setupLayout() {
        view.addSubviewForAutoLayout(tableView)
        tableView.layout(with: view).fill()
        
        if viewModel.showsDoneButton {
            view.addSubviewForAutoLayout(doneButton)
            
            doneButton.layout().height(Layout.doneButtonHeight)
            doneButton.layout().width(Layout.doneButtonMinimumWidth,
                                      relatedBy: .greaterThanOrEqual)
            
            safeBottomAnchor.constraint(greaterThanOrEqualTo: doneButton.bottomAnchor).priority = .defaultHigh
            safeBottomAnchor.constraint(greaterThanOrEqualTo: doneButton.bottomAnchor).isActive = true
            
            doneButton.layout(with: keyboardView).bottom(to: .top,
                                                         by: -(Layout.doneButtonHeight + (Metrics.veryBigMargin*2)),
                                                         priority: .defaultLow)
            
            doneButton.layout(with: view).right(by: -Metrics.bigMargin)
        }
    }
    
    @objc private func doneButtonTapped() {
        switch viewModel.type {
        case .multiselect(let multiselectModel):
            multiselectModel.doneButtonTapped()
        case .singleSelect: break
        }
    }
    
    private func showDoneButton() {
        if !doneButton.isEnabled {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.doneButton.alpha = 1
                self?.doneButton.isEnabled = true
            }
        }
    }
    
    private func hideDoneButton() {
        doneButton.alpha = 0
        doneButton.isEnabled = false
    }
}

extension ListingAttributePickerViewController: ListingAttributePickerTableViewDelegate {
    
    func indexSelected(index: Int) {
        viewModel.indexSelected(index: index)
        showDoneButton()
    }
    
    func indexDeselected(index: Int) {
        viewModel.indexDeselected(index: index)
        showDoneButton()
    }
    
    func indexForValueSelected() -> Int? {
        return viewModel.indexForValueSelected()
    }

}
