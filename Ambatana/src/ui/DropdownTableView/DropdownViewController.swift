import LGComponents

final class DropdownViewController: KeyboardViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, DropdownViewModelDelegate {
    
    private enum Layout {
        static let searchBoxHeight: CGFloat = 44
        static let gradientHeight: CGFloat = 500
        static let doneButtonHeight: CGFloat = 44
        static let doneButtonMinimumWidth: CGFloat = 114
        static let showMoreHeight: CGFloat = 40
    }
    
    private let viewModel: DropdownViewModel
    private let keyboardHelper: KeyboardHelper
    
    //  MARK: - Subviews
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tintColor = .white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.bigMargin*4, right: 0)
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: CGFloat.leastNormalMagnitude))
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        
        tableView.register(DropdownShowMoreView.self,
                           forHeaderFooterViewReuseIdentifier: DropdownShowMoreView.reusableID)
        tableView.register(type: DropdownHeaderCell.self)
        tableView.register(type: DropdownItemCell.self)
        
        return tableView
    }()
    
    private let searchBar = LGPickerSearchBar(withStyle: .darkContent, clearButtonMode: .always)
    
    private let gradient: GradientView = {
        let gradient = GradientView(colors: [UIColor.white.withAlphaComponent(0.0),
                                             .white],
                                    locations: [0.75, 1.0])
        gradient.isUserInteractionEnabled = false
        return gradient
    }()
    
    private let doneButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.alpha = 0
        button.setTitle(R.Strings.commonDone, for: .normal)
        return button
    }()
    
    private lazy var resetButton: UIBarButtonItem = {
        let resetButton = UIBarButtonItem(title: R.Strings.filtersNavbarReset,
                                          style: UIBarButtonItemStyle.plain,
                                          target: self,
                                          action: #selector(resetButtonTapped))
        resetButton.tintColor = .primaryColor
        return resetButton
    }()
    
    //  MARK: - Lifecycle
    
    convenience init(withViewModel viewModel: DropdownViewModel) {
        self.init(viewModel: viewModel,
                  keyboardHelper: KeyboardHelper())
    }
    
    private init(viewModel: DropdownViewModel, keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        super.init(viewModel: nil, nibName: nil)
        self.viewModel.delegate = self
        setupAccessibilityIds()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .dropdownViewControllerTableView)
        searchBar.set(accessibilityId: .dropdownViewControllerSearchBar)
        doneButton.set(accessibilityId: .dropdownViewControllerApplyButton)
        resetButton.set(accessibilityId: .dropdownViewControllerResetButton)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = viewModel.screenTitle
        
        doneButton.addTarget(self,
                             action: #selector(doneButtonTapped),
                             for: .touchUpInside)

        hideDoneButton()
        showResetButton()
        addSubViews()
        addConstraints()
        setupTableView()
        setupSearchBar()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = viewModel.searchPlaceholderTitle
        searchBar.delegate = self
    }
    
    private func addSubViews() {
        view.addSubviewsForAutoLayout([searchBar, tableView, gradient, doneButton])
    }
    
    private func addConstraints() {
        
        let searchConstraints = [searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
                                 searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
                                 searchBar.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.margin),
                                 searchBar.heightAnchor.constraint(equalToConstant: Layout.searchBoxHeight)]
        
        let tableContraints = [tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                               tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                               tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Metrics.margin),
                               tableView.bottomAnchor.constraint(equalTo: safeBottomAnchor)]
        
        let gradientConstraints = [gradient.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                                   gradient.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                                   gradient.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
                                   gradient.heightAnchor.constraint(equalToConstant: Layout.gradientHeight)]
        
        let buttonConstraints = [doneButton.heightAnchor.constraint(equalToConstant: Layout.doneButtonHeight),
                                 doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.doneButtonMinimumWidth),
                                 doneButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -Metrics.bigMargin),
                                 doneButton.bottomAnchor.constraint(equalTo: keyboardView.topAnchor, constant: -Metrics.veryBigMargin)]

        NSLayoutConstraint.activate([searchConstraints,
                                     tableContraints,
                                     gradientConstraints,
                                     buttonConstraints].flatMap { $0 })
    }


    
    // MARK: Button Actions
    
    @objc private func doneButtonTapped() {
        viewModel.applySelectedFilters()
    }
    
    @objc private func resetButtonTapped() {
        viewModel.resetFilters()
        tableView.reloadData()
    }
    

    // MARK: UITableViewDataSource Implementation
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(forSection: section)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.item(forIndexPath: indexPath) else { return UITableViewCell() }
        switch item.content.type {
        case .header:
            guard let cell = tableView.dequeue(type: DropdownHeaderCell.self,
                                               for: indexPath) else {
                                                return UITableViewCell()
            }
            
            let isExpanded = viewModel.expansionState(forId: item.content.id)
            
            cell.setup(withRepresentable: item,
                       isExpanded: isExpanded,
                       showsChevron: viewModel.showsHeaderChevron,
                       checkboxAction: { [weak self, indexPath] in
                        self?.viewModel.toggleHeaderSelection(atIndexPath: indexPath)
                        self?.reloadView()
            })

            updateTableViewSelectionState(cellState: item.state, atIndexPath: indexPath)
            
            return cell
        case .item:
            guard let cell = tableView.dequeue(type: DropdownItemCell.self,
                                               for: indexPath) else {
                                                return UITableViewCell()
            }
            
            cell.setup(withRepresentable: item)
            updateTableViewSelectionState(cellState: item.state, atIndexPath: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        guard let sectionContent = viewModel.dropdownSection(atSection: section),
            !sectionContent.isShowingAll, sectionContent.isExpanded else { return nil }
        
        let reuseableView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DropdownShowMoreView.reusableID) as? DropdownShowMoreView
        
        reuseableView?.setupSelectShowMoreAction(didSelectShowMoreAction: { [weak self, sectionContent] in
            sectionContent.isShowingAll = true
            self?.reloadView()
        })
        return reuseableView
    }


    // MARK: UITableViewDelegate Implementation
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.itemHeight(atIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        guard let section = viewModel.dropdownSection(atSection: section),
            !section.isShowingAll, section.isExpanded else { return CGFloat.leastNormalMagnitude }
        
        return Layout.showMoreHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.didDeselectItem(atIndexPath: indexPath)
    }


    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.clearTextFilter()
        } else {
            viewModel.didFilter(withText: searchText)
        }
        
        reloadView()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }


    // MARK: DropdownViewModelDelegate

    func selectRow(atIndexPath indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        reloadView()
    }
    
    func deselectRow(atIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        reloadView()
    }
    
    func showDoneButton() {
        doneButton.animateTo(alpha: 1.0)
    }
    
    func hideDoneButton() {
        doneButton.animateTo(alpha: 0.0)
    }
    
    func showResetButton() {
        navigationItem.rightBarButtonItem = resetButton
    }
    
    private func reloadView() {
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        tableView.reloadData()
        selectedIndexPaths?.forEach({ indexPath in
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        })
    }
    
    
    // MARK: Helpers
    
    private func toggleCellSelection(toState state: DropdownCellState,
                                     forIndexPath indexPath: IndexPath) {
        guard let cell = tableView.dequeue(type: DropdownItemCell.self, for: indexPath) else { return }
        cell.updateState(state: state, animated: true)
    }
    
    private func updateTableViewSelectionState(cellState state: DropdownCellState,
                                               atIndexPath indexPath: IndexPath) {
        switch state {
        case .selected, .semiSelected:
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        case .deselected:
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}
