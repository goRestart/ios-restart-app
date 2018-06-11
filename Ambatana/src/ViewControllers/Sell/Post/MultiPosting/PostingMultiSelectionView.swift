import LGCoreKit
import LGComponents

protocol PostingMultiSelectionViewDelegate: class {
    func add(service subtype: ServiceSubtype)
    func remove(service subtype: ServiceSubtype)
    func addNew(service name: String)
    func removeNew(service name: String)
    func showAlertMaxSelection()
}

final class PostingMultiSelectionView: UIView {
    
    var theme: ListingAttributePickerCell.Theme = .dark

    weak var delegate: PostingMultiSelectionViewDelegate?

    private var filteredValues: [String]
    private let rawValues: [String]
    private var selectedIndexes: [IndexPath] = []
    private let subtypes: [ServiceSubtype]
    private let highlightedItems: [String]
    private var newSubtypes: [String] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(type: PostMultiSelectionCell.self)
        tableView.register(type: PostAddNewCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tintColor = .white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.margin, right: 0)
        tableView.allowsMultipleSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        return tableView
    }()
    
    private var selectedFiltersTagsViewModel = TagCollectionViewModel(tags: [], cellStyle: .blackBackgroundWithCross)
    private var selectedFiltersTags: TagCollectionView
    
    private let searchBar = LGPickerSearchBar(withStyle: .lightContent)
    
    private let gradient = GradientView(colors: [.clear, .lgBlack], locations: [0.75, 1.0])
    
    private var tagsHeightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    private var selectedServicesIsLessThanMax: Bool {
        return (selectedIndexes.count + newSubtypes.count) < Constants.maxNumberMultiPosting
    }
    
    // MARK: - Lifecycle
    
    init(theme: ListingAttributePickerCell.Theme,
         subtypes: [ServiceSubtype]) {
        let highlightedItems = subtypes.filter { $0.isHighlighted }
        let subtypesNames = subtypes.map { $0.name }
        self.theme = theme
        self.subtypes = subtypes
        self.rawValues = subtypesNames
        self.highlightedItems = highlightedItems.map { $0.name }
        self.filteredValues = highlightedItems.map { $0.name }
        self.selectedIndexes = []
        self.selectedFiltersTags = TagCollectionView(viewModel: selectedFiltersTagsViewModel, flowLayout: .singleRowWithScroll)
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviewsForAutoLayout([searchBar, selectedFiltersTags, tableView, gradient])
        setupSearchBar()
        setupCollectionTags()
        setupTableView()
        gradient.isUserInteractionEnabled = false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        reloadTableView(withValues: highlightedItems)
    }
    
    private func setupCollectionTags() {
        selectedFiltersTagsViewModel.selectionDelegate = self
        selectedFiltersTags.contentInset = UIEdgeInsets(top: 0, left: Metrics.margin, bottom: 0, right: 0)
    }

    private func setupSearchBar() {
        searchBar.placeholder = R.Strings.postDetailsServicesSearchPlaceholder
        searchBar.cornerRadius = 8
        searchBar.delegate = self
    }
    
    private func setupConstraints() {
        searchBar.layout()
            .height(Layout.searchHeight)
        searchBar.layout(with: self)
            .top(by: Metrics.margin)
            .fillHorizontal(by: Metrics.margin)
        searchBar
            .layout(with: selectedFiltersTags)
            .bottom(to: .top, by: -Metrics.margin)
        
        selectedFiltersTags.layout(with: self).fillHorizontal()

        tagsHeightConstraint = selectedFiltersTags.heightAnchor.constraint(equalToConstant: 0)
        bottomConstraint = selectedFiltersTags.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0)
        if let tagsHeightConstraint = tagsHeightConstraint, let bottomConstraint = bottomConstraint {
            NSLayoutConstraint.activate([tagsHeightConstraint, bottomConstraint])
        }
        
        tableView.layout(with: self)
            .bottom()
            .fillHorizontal(by: Metrics.margin)
        gradient.layout(with: self).fillHorizontal()
        gradient.layout(with: tableView).fillVertical()
    }
    
    private func updateFilterTagsSize(withValues values: [String]) {
        tagsHeightConstraint?.constant = values.isEmpty ? 0.0 : Layout.tagsHeight
        bottomConstraint?.constant = values.isEmpty ? 0.0 : -Metrics.margin
        UIView.animate(withDuration: 0.3) { self.layoutIfNeeded() }
    }
    
    // MARK: - Accessibility
    
    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .postingAddDetailTableView)
        searchBar.set(accessibilityId: .postingCategoryDeatilSearchBar)
    }
    
    //  MARK: - private

    private func reloadTableView(withValues values: [String]) {
        filteredValues = values
        tableView.reloadData()
    }
    
    private struct Layout {
        static let cellSize: CGFloat = 67
        static let searchHeight: CGFloat = 44
        static let tagsHeight: CGFloat = 33
    }
    
}

extension PostingMultiSelectionView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK:- UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            reloadTableView(withValues: highlightedItems)
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
        if section == 0 {
            return filteredValues.count
        }
        return filteredValues.count > 0 ? 0 : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostMultiSelectionCell.reusableID) as? PostMultiSelectionCell else {
                return UITableViewCell()
            }
            let value = filteredValues[indexPath.row]
            cell.configure(with: value, theme: theme)
            updateTableViewSelections(indexPath, tableView)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PostAddNewCell.reusableID) as? PostAddNewCell else {
                return UITableViewCell()
            }
            cell.title = R.Strings.postDetailsServicesAddNew
            return cell
        }
    }
    
    private func updateTableViewSelections(_ indexPath: IndexPath, _ tableView: UITableView) {
        if let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            selectedIndexes.contains(where: { $0 ==  rawIndexPath } ) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard selectedServicesIsLessThanMax else {
            delegate?.showAlertMaxSelection()
            return
        }
        
        if indexPath.section == 0 {
            guard let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
                !selectedIndexes.contains(where: { $0 ==  rawIndexPath } ) else { return }
            selectedIndexes.insert(rawIndexPath, at: 0)
            tableView.cellForRow(at: indexPath)?.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            refreshTags()
            if subtypes.count > rawIndexPath.row {
                delegate?.add(service: subtypes[rawIndexPath.row])
            }
        } else {
            addNewTypeAndResetSearch()
        }
    }
    
    private func addNewTypeAndResetSearch() {
        guard let newItemTitle = searchBar.text,
            !newItemTitle.isEmpty,
            !newSubtypes.contains(newItemTitle) else { return }
        delegate?.addNew(service: newItemTitle)
        newSubtypes.append(newItemTitle)
        filteredValues = highlightedItems
        searchBar.text = nil
        refreshTags()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        guard let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            let rawIndex = selectedIndexes.index(of: rawIndexPath) else { return }
        selectedIndexes.remove(at: rawIndex)
        tableView.cellForRow(at: indexPath)?.isSelected = false
        tableView.deselectRow(at: indexPath, animated: false)
        refreshTags()
        if subtypes.count > rawIndexPath.row {
            delegate?.remove(service: subtypes[rawIndexPath.row])
        }
    }
    
    private func convertFilteredIndexPathToRawIndexPath(filteredIndexPath: IndexPath) -> IndexPath? {
        guard let item = filteredValues[safeAt: filteredIndexPath.row],
            let rawIndex = rawValues.index(of: item) else {
                return nil
        }
        return IndexPath(row: rawIndex, section: 0)
    }
    
    private func refreshTags() {
        updateFilterTagsSize(withValues: tags)
        selectedFiltersTagsViewModel.tags = tags
        selectedFiltersTags.reloadData()
    }
    
    private var tags: [String] {
        let tags = selectedIndexes.flatMap { rawValues[safeAt: $0.row] }
        return newSubtypes + tags
    }

}

extension PostingMultiSelectionView: TagCollectionViewModelSelectionDelegate {
    func vm(_ vm: TagCollectionViewModel, didSelectTagAtIndex index: Int) {
        guard let tag = vm.tags[safeAt: index] else { return }
        if let indexInTable = rawValues.index(of: tag) {
            selectedIndexes = selectedIndexes.filter { $0.row != indexInTable }
            if let subtype = subtypes.first(where: { $0.name == tag }) {
                delegate?.remove(service: subtype)
            }
        } else if let newStyleIndex = newSubtypes.index(of: tag) {
            newSubtypes.remove(at: newStyleIndex)
            delegate?.removeNew(service: tag)
        }
        refreshTags()
        tableView.reloadData()
    }
}

extension PostingMultiSelectionView: PostingViewConfigurable {
    
    func setupContainerView(view: UIView) {
        view.addSubviewForAutoLayout(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) { }
    
}
