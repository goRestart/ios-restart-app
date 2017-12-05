import RxSwift
import LGCoreKit

protocol ListingAttributePickerTableViewDelegate: class {
    func indexSelected(index: Int)
    func indexDeselected(index: Int)
    func findValueSelected() -> Int?
}

class ListingAttributePickerTableView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var theme: ListingAttributePickerCell.Theme {
        return .dark
    }
    private var detailInfo: [String]
    fileprivate let tableView = UITableView()
    fileprivate var selectedValue: IndexPath?
    weak var delegate: ListingAttributePickerTableViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(values: [String], selectedIndex: IndexPath?, delegate: ListingAttributePickerTableViewDelegate?) {
        self.detailInfo = values
        self.delegate = delegate
        self.selectedValue = selectedIndex
        super.init(frame: CGRect.zero)
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Layout
    
    private func setupUI() {
        tableView.register(ListingAttributePickerCell.self, forCellReuseIdentifier: ListingAttributePickerCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = .clear
        tableView.tintColor = UIColor.white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
        tableView.allowsMultipleSelection = true
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        tableView.layout(with: self)
            .top()
            .bottom()
            .leading()
            .trailing()
        setupTableView(values: detailInfo)
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.accessibilityId = .postingAddDetailTableView
    }
    
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailInfo.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListingAttributePickerCell.Theme.light.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ListingAttributePickerCell.identifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ListingAttributePickerCell else {
            return UITableViewCell()
        }
        let value = detailInfo[indexPath.row]
        cell.configure(with: value, theme: theme)
        if selectedValue == indexPath {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedValue = indexPath
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        delegate?.indexSelected(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedValue = nil
        tableView.cellForRow(at: indexPath)?.isSelected = false
        delegate?.indexDeselected(index: indexPath.row)
    }
    
    fileprivate func setupTableView(values: [String]) {
        detailInfo = values
        tableView.reloadData()
    }
}

class PostingAttributePickerTableView: ListingAttributePickerTableView, PostingViewConfigurable {
    
    override var theme: ListingAttributePickerCell.Theme {
        return .light
    }
    
    func setupView(viewModel: PostingDetailsViewModel) {
        guard let positionSelected = viewModel.findValueSelected() else { return }
        let indexPath = IndexPath(row: positionSelected, section: 0)
        selectedValue = indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
}
