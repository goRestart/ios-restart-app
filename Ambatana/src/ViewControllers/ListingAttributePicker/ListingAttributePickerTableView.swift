import RxSwift
import LGCoreKit
import LGComponents

protocol ListingAttributePickerTableViewDelegate: class {
    func indexSelected(index: Int)
    func indexDeselected(index: Int)
    func indexForValueSelected() -> Int?
}

class ListingAttributePickerTableView: UIView, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    internal var theme: ListingAttributePickerCell.Theme {
        return .dark
    }
    
    private var filteredValues: [String]
    private let rawValues: [String]
    private let allowsMultiselect: Bool
    
    internal let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ListingAttributePickerCell.self, forCellReuseIdentifier: ListingAttributePickerCell.reusableID)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = .clear
        tableView.tintColor = UIColor.white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
        return tableView
    }()
    
    private let searchBar = LGPickerSearchBar(withStyle: .darkContent)

    internal var selectedIndexes: [IndexPath]
    weak var delegate: ListingAttributePickerTableViewDelegate?
    private let showsSearchBar: Bool
    
    // MARK: - Lifecycle
    
    convenience init(values: [String],
                     selectedIndexes: [IndexPath],
                     delegate: ListingAttributePickerTableViewDelegate?) {
        self.init(values: values,
                  selectedIndexes: selectedIndexes,
                  delegate: delegate,
                  showsSearchBar: false,
                  allowsMultiselect: false)
    }
    
    init(values: [String],
         selectedIndexes: [IndexPath],
         delegate: ListingAttributePickerTableViewDelegate?,
         showsSearchBar: Bool,
         allowsMultiselect: Bool) {
        self.rawValues = values
        self.filteredValues = values
        self.delegate = delegate
        self.selectedIndexes = selectedIndexes
        self.showsSearchBar = showsSearchBar
        self.allowsMultiselect = allowsMultiselect
        super.init(frame: CGRect.zero)
        setupUI()
        setupAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if theme.gradientEnabled { applyGradient() }
    }
    
    
    // MARK: - Layout
    
    private func setupUI() {
        setupTableView()
        setupSearchBar()
        setupLayout()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = allowsMultiselect
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
    }
    
    private func setupLayout() {
        if showsSearchBar {
            setupTableViewWithSearchBarLayout()
        } else {
            setupTableViewOnlyLayout()
        }
    }
    
    private func setupTableViewWithSearchBarLayout() {
        let subviews = [searchBar, tableView]
        addSubviewsForAutoLayout(subviews)
        
        searchBar.layout()
            .height(44)
        searchBar.layout(with: self)
            .top(by: Metrics.margin)
            .fillHorizontal(by: Metrics.margin)
        searchBar.layout(with: tableView)
            .bottom(to: .top, by: -Metrics.margin)
        tableView.layout(with: self)
            .bottom()
            .fillHorizontal(by: Metrics.margin)
        reloadTableView(withValues: rawValues)
    }
    
    private func setupTableViewOnlyLayout() {
        addSubviewForAutoLayout(tableView)
        
        tableView.layout(with: self)
            .fillVertical()
            .fillHorizontal()
        reloadTableView(withValues: rawValues)
    }
    
    private func applyGradient() {
        let gradient = CAGradientLayer()
        
        gradient.frame = (tableView.superview?.bounds)!
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.75, 1.0]
        tableView.superview?.layer.mask = gradient
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .postingAddDetailTableView)
        searchBar.set(accessibilityId: .postingCategoryDeatilSearchBar)
    }
    
    
    // MARK:- UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            reloadTableView(withValues: rawValues)
        } else {
            let filter = rawValues.filter( { $0.lowercased().contains(searchText.lowercased()) } )
            reloadTableView(withValues: filter)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredValues.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return theme.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = ListingAttributePickerCell.reusableID
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ListingAttributePickerCell else {
            return UITableViewCell()
        }
        let value = filteredValues[indexPath.row]
        cell.configure(with: value, theme: theme)
        if let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            selectedIndexes.contains(where: { $0 ==  rawIndexPath } ) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        tableView.deselectRow(at: indexPath, animated: false)
        if let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            selectedIndexes.contains(where: { $0 ==  rawIndexPath } ) {
            selectedIndexes = selectedIndexes.filter( { $0 != rawIndexPath } )
            delegate?.indexDeselected(index: indexPath.row)
            return nil // cancel the selection that triggered the event
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            !selectedIndexes.contains(where: { $0 ==  rawIndexPath } ) else { return }
        selectedIndexes.append(rawIndexPath)
        tableView.cellForRow(at: indexPath)?.isSelected = true
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        delegate?.indexSelected(index: rawIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndexes = selectedIndexes.filter( { $0 != indexPath } )
        tableView.cellForRow(at: indexPath)?.isSelected = false
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.indexDeselected(index: indexPath.row)
    }
    
    fileprivate func reloadTableView(withValues values: [String]) {
        filteredValues = values
        tableView.reloadData()
    }
    
    fileprivate func convertFilteredIndexPathToRawIndexPath(filteredIndexPath: IndexPath) -> IndexPath? {
        guard let item = filteredValues[safeAt: filteredIndexPath.row],
            let rawIndex = rawValues.index(of: item) else {
            return nil
        }
        return IndexPath(row: rawIndex, section: 0)
    }
}

final class PostingAttributePickerTableView: ListingAttributePickerTableView, PostingViewConfigurable {
    
    override var theme: ListingAttributePickerCell.Theme {
        return .light
    }
    
    func setupView(viewModel: PostingDetailsViewModel) {
        guard let positionSelected = viewModel.indexForValueSelected() else { return }
        let indexPath = IndexPath(row: positionSelected, section: 0)
        selectedIndexes = [indexPath]
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
}
