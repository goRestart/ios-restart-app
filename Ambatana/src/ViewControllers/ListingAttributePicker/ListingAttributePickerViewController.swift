
class ListingAttributePickerViewController: BaseViewController {
    
    fileprivate let tableView: ListingAttributePickerTableView
    fileprivate let viewModel: ListingAttributePickerViewModel
    
    init(viewModel: ListingAttributePickerViewModel) {
        self.viewModel = viewModel
        var selectedIndexPath: IndexPath?
        if let index = viewModel.selectedIndex {
            selectedIndexPath = IndexPath(row: index, section: 0)
        }
        tableView = ListingAttributePickerTableView(values: viewModel.attributes,
                                                    selectedIndex: selectedIndexPath,
                                                    delegate: nil,
                                                    showsSearchBar: viewModel.canSearchAttributes)
        super.init(viewModel: viewModel, nibName: nil)
        tableView.delegate = self
        self.title = viewModel.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
}

fileprivate extension ListingAttributePickerViewController {
    
    func setupViews() {
        edgesForExtendedLayout = []
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layout(with: view).fill()
    }
}

extension ListingAttributePickerViewController: ListingAttributePickerTableViewDelegate {
    
    func indexSelected(index: Int) {
        viewModel.selectedAttribute(at: index)
    }
    
    func indexDeselected(index: Int) {
        viewModel.deselectAttribute()
    }
    
    func indexForValueSelected() -> Int? {
        return viewModel.selectedIndex
    }
}
