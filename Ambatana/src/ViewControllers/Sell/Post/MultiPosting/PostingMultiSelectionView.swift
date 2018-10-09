import LGCoreKit
import LGComponents
import RxSwift

protocol PostingMultiSelectionViewDelegate: class {
    func add(service subtype: ServiceSubtype)
    func remove(service subtype: ServiceSubtype)
    func addNew(service name: String)
    func removeNew(service name: String)
    func removeAllServices()
    func removeAllNew()
    func showAlertMaxSelection()
}

protocol PostingMultiSelectionScrollDelegate: class {
    func scroll(_ scrollView: UIScrollView)
    func scrollToTop()
}

final class PostingMultiSelectionView: UIView {
    
    private struct Layout {
        static let tableViewBottomInset: CGFloat = Metrics.veryBigMargin*4
        static let cellSize: CGFloat = 67
        static let searchHeight: CGFloat = 44
        static let tagsHeight: CGFloat = 33
        static let shadowHeight: CGFloat = 500
    }
    
    private let disposeBag = DisposeBag()
    
    var theme: ListingAttributePickerCell.Theme = .dark

    weak var delegate: PostingMultiSelectionViewDelegate?
    weak var scrollDelegate: PostingMultiSelectionScrollDelegate?

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
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: Layout.tableViewBottomInset,
                                              right: 0)
        tableView.allowsMultipleSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 150, height: 33)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: Metrics.margin, bottom: 0, right: 0)
        collectionView.register(type: TagCollectionViewWithCloseCell.self)
        return collectionView
    }()
    
    private let searchBar = LGPickerSearchBar(withStyle: .lightContent)
    
    private let gradient = GradientView(colors: [.clear, .lgBlack], locations: [0.75, 1.0])
    
    private var tagsHeightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    
    private var selectedServicesIsLessThanMax: Bool {
        return (selectedIndexes.count + newSubtypes.count) < SharedConstants.maxNumberMultiPosting
    }
    
    private var shouldShowMaxSelectionAlert: Bool {
        switch serviceListingType {
        case .service:
            return true
        case .job:
            return false
        }
    }
    
    private let keyboardHelper: KeyboardHelper
    private let serviceListingType: ServiceListingType
    
    
    // MARK: - Lifecycle
    
    init(keyboardHelper: KeyboardHelper,
         theme: ListingAttributePickerCell.Theme,
         subtypes: [ServiceSubtype],
         serviceListingType: ServiceListingType) {
        let highlightedItems = subtypes.filter { $0.isHighlighted }
        let subtypesNames = subtypes.map { $0.name }
        self.keyboardHelper = keyboardHelper
        self.theme = theme
        self.subtypes = subtypes
        self.rawValues = subtypesNames
        self.highlightedItems = highlightedItems.map { $0.name }
        self.filteredValues = highlightedItems.map { $0.name }
        self.selectedIndexes = []
        self.serviceListingType = serviceListingType
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        setupAccessibilityIds()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setupUI() {
        addSubviewsForAutoLayout([searchBar, collectionView, tableView, gradient])
        setupSearchBar()
        setupCollectionTags()
        setupTableView()
        gradient.isUserInteractionEnabled = false
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        reloadTableView(withValues: highlightedItems)
    }
    
    private func setupCollectionTags() {
        collectionView.delegate = self
        collectionView.dataSource = self
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
            .layout(with: collectionView)
            .bottom(to: .top, by: -Metrics.margin)
        
        collectionView.layout(with: self).fillHorizontal()
        
        tagsHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: 0)
        if let tagsHeightConstraint = tagsHeightConstraint, let bottomConstraint = bottomConstraint {
            NSLayoutConstraint.activate([tagsHeightConstraint, bottomConstraint])
        }
        
        tableView.layout(with: self)
            .bottom()
            .fillHorizontal(by: Metrics.margin)
        gradient.layout(with: self).fillHorizontal().bottom()
        gradient.layout().height(Layout.shadowHeight)
        
    }
    
    private func setupRx() {
        
        keyboardHelper.rx_keyboardOrigin
            .asObservable()
            .skip(1)
            .distinctUntilChanged()
            .bind { [weak self] origin in
                guard let keyboardHeight = self?.keyboardHelper.keyboardHeight else { return }
                let keyboardVisible: Bool = origin < UIScreen.main.bounds.height
                self?.tableView.contentInset.bottom = keyboardVisible ? (keyboardHeight + Metrics.shortMargin) : Layout.tableViewBottomInset
                if keyboardVisible {
                    self?.scrollDelegate?.scrollToTop()
                }
            }.disposed(by: disposeBag)
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
    
    private func clearAllSelectedIfNecessary() {
        switch serviceListingType {
        case .job:
            delegate?.removeAllNew()
            delegate?.removeAllServices()
            newSubtypes.removeAll()
            selectedIndexes.removeAll()
            tableView.reloadData()
            collectionView.reloadData()
        case .service: break
        }
    }
}

extension PostingMultiSelectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeue(type: TagCollectionViewWithCloseCell.self, for: indexPath),
            let tag = tags[safeAt: indexPath.row] else { return UICollectionViewCell() }
        cell.setupWith(style: .blackBackgroundWithCross)
        cell.configure(with: tag)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collection(didSelectTagAtIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellText = tags[safeAt: indexPath.row] else { return .zero }
        return TagCollectionViewWithCloseCell.cellSizeForText(text: cellText, style: .blackBackgroundWithCross)
    }
}

extension PostingMultiSelectionView: UISearchBarDelegate {
    
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
    
}

extension PostingMultiSelectionView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filteredValues.count
        }
        return filteredValues.count > 0 ? 0 : 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellSize
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    private func updateTableViewSelections(_ indexPath: IndexPath,
                                           _ tableView: UITableView) {
        if let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            selectedIndexes.contains(where: { $0 ==  rawIndexPath } ) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        clearAllSelectedIfNecessary()

        guard selectedServicesIsLessThanMax else {
            if shouldShowMaxSelectionAlert {
                delegate?.showAlertMaxSelection()
            }
            return
        }
        
        if indexPath.section == 0 {
            guard let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
                !selectedIndexes.contains(where: { $0 ==  rawIndexPath } ),
                let subtype = subtypes[safeAt: rawIndexPath.row],
                subtypes.count > rawIndexPath.row else { return }
            
            selectedIndexes.insert(rawIndexPath, at: 0)
            tableView.cellForRow(at: indexPath)?.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
            delegate?.add(service: subtype)
            didAddNewTag()
        } else {
            addNewTypeAndResetSearch()
        }
        endEditing(true)
    }
    
    private func addNewTypeAndResetSearch() {
        guard let newItemTitle = searchBar.text,
            !newItemTitle.isEmpty,
            !newSubtypes.contains(newItemTitle) else { return }
        delegate?.addNew(service: newItemTitle)
        newSubtypes.append(newItemTitle)
        filteredValues = highlightedItems
        searchBar.text = nil
        didAddNewTag()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        guard let rawIndexPath = convertFilteredIndexPathToRawIndexPath(filteredIndexPath: indexPath),
            let rawIndex = selectedIndexes.index(of: rawIndexPath),
            let subtype = subtypes[safeAt: rawIndexPath.row],
            let indexCollection = tags.index(where: { $0 == subtype.name }),
            subtypes.count > rawIndexPath.row else { return }
        
        selectedIndexes.remove(at: rawIndex)
        tableView.cellForRow(at: indexPath)?.isSelected = false
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.remove(service: subtype)
        reloadTag(at: indexCollection)
    }
    
    private func convertFilteredIndexPathToRawIndexPath(filteredIndexPath: IndexPath) -> IndexPath? {
        guard let item = filteredValues[safeAt: filteredIndexPath.row],
            let rawIndex = rawValues.index(of: item) else {
                return nil
        }
        return IndexPath(row: rawIndex, section: 0)
    }
    
    private var tags: [String] {
        let tags = selectedIndexes.compactMap { rawValues[safeAt: $0.row] }
        return newSubtypes + tags
    }
    
    private func collection(didSelectTagAtIndex index: Int) {
        guard let tag = tags[safeAt: index] else { return }
        if let indexInTable = rawValues.index(of: tag) {
            selectedIndexes = selectedIndexes.filter { $0.row != indexInTable }
            if let subtype = subtypes.first(where: { $0.name == tag }) {
                delegate?.remove(service: subtype)
            }
        } else if let newStyleIndex = newSubtypes.index(of: tag) {
            newSubtypes.remove(at: newStyleIndex)
            delegate?.removeNew(service: tag)
        }
        reloadTag(at: index)
        tableView.reloadData()
    }
    
    private func reloadTag(at index: Int) {
        updateFilterTagsSize(withValues: tags)
        
        //  It seems an error in iOS 10 issue when reloadData.
        //  More info: https://stackoverflow.com/a/40081444/2000162
        if #available(iOS 10, *) {
            collectionView.reloadSections(IndexSet(integer: 0))
        } else {
            collectionView.reloadData()
        }
    }
    
    private func didAddNewTag() {
        updateFilterTagsSize(withValues: tags)

        switch serviceListingType {
        case .service:
            addTagAtFirst()
        case .job:
            collectionView.reloadData()
        }
    }
    
    private func addTagAtFirst() {
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        }) { _ in
            self.collectionView.reloadData()
        }
    }
    
}

extension PostingMultiSelectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scroll(scrollView)
    }
}

extension PostingMultiSelectionView: PostingViewConfigurable {
    
    func setupContainerView(view: UIView) {
        view.addSubviewForAutoLayout(self)
        layout(with: view).fill()
    }
    
    func setupView(viewModel: PostingDetailsViewModel) { }
    
}
