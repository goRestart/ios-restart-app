import LGComponents
import RxSwift
import MessageUI


final class AffiliationInviteSMSContactsViewController: KeyboardViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {
    
    private enum Layout {
        static let searchBoxHeight: CGFloat = 44
        static let inviteButtonHeight: CGFloat = 44
        static let inviteButtonMinimumWidth: CGFloat = 114
        static let contactCellHeight: CGFloat = 60
    }
    
    private let viewModel: AffiliationInviteSMSContactsViewModel
    private let keyboardHelper: KeyboardHelper
    
    private let emptyState = InviteSMSContactsEmptyStateView()
    
    private let tableViewSearchResults: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.tintColor = .white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.bigMargin*4, right: 0)
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = Layout.contactCellHeight
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: CGFloat.leastNormalMagnitude))
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        
        tableView.register(type: AffiliationInviteSMSContactsCell.self)
        return tableView
    }()
    
    
    private let tableViewAllContacts: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.tintColor = .white
        tableView.indicatorStyle = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: Metrics.bigMargin*4, right: 0)
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.estimatedRowHeight = Layout.contactCellHeight
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: CGFloat.leastNormalMagnitude))
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        
        tableView.register(type: AffiliationInviteSMSContactsCell.self)
        return tableView
    }()
    
    private let searchBar = LGPickerSearchBar(withStyle: .darkContent, clearButtonMode: .always)
    
    private let inviteButton: LetgoButton = {
        let button = LetgoButton(withStyle: .primary(fontSize: .big))
        button.setTitle(R.Strings.affiliationInviteFriendsTitle, for: .normal)
        return button
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    var datasourceAllContacts: [ContactInfo] {
        return viewModel.contactsInfo.value
    }
    
    var datasourceSearchResults: [ContactInfo] {
        return viewModel.searchResultsInfo.value
    }
    
    // MARK: Lifecycle
    
    convenience init(viewModel: AffiliationInviteSMSContactsViewModel) {
        self.init(viewModel: viewModel,
                  keyboardHelper: KeyboardHelper())
    }
    
    init(viewModel: AffiliationInviteSMSContactsViewModel,
         keyboardHelper: KeyboardHelper) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil)
        setupUI()
        setupRx()
        setupTableView()
        setupSearchBar()
        setupConstraints()
        setAccessibilityIds()
    }
    
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchBar.resignFirstResponder()
    }
    
    private func setupUI() {
        title = R.Strings.affiliationInviteSmsContactsTitle
        view.backgroundColor = .white
        inviteButton.addTarget(self,
                               action: #selector(doneButtonTapped),
                               for: .touchUpInside)
    }
    
    private func setupTableView() {
        tableViewAllContacts.delegate = self
        tableViewAllContacts.dataSource = self
        tableViewSearchResults.delegate = self
        tableViewSearchResults.dataSource = self
    }
    
    
    func setupRx() {
        viewModel.contactsInfo.asDriver().drive(onNext: { [weak self] _ in
            self?.viewModel.updateFirstLetterPositions()
            self?.tableViewAllContacts.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.hasContactsSelected.asObservable().bind(to: inviteButton.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel.status.asDriver().drive(onNext: { [weak self] status in
            self?.update(with: status)
        }).disposed(by: disposeBag)
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = R.Strings.affiliationInviteSmsContactsSearchPlaceholder
        searchBar.delegate = self
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([searchBar,
                                       tableViewAllContacts,
                                       tableViewSearchResults,
                                       inviteButton])
        let tableViewSearchResultsConstraints = [
            tableViewSearchResults.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewSearchResults.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewSearchResults.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor),
            tableViewSearchResults.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Metrics.margin)
        ]
        
        let tableViewAllContactsConstraints = [
            tableViewAllContacts.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewAllContacts.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewAllContacts.bottomAnchor.constraint(equalTo: bottomLayoutGuide.bottomAnchor),
            tableViewAllContacts.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Metrics.margin)
        ]
        
        let searchConstraints = [searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Metrics.margin),
                                 searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Metrics.margin),
                                 searchBar.topAnchor.constraint(equalTo: safeTopAnchor, constant: Metrics.margin),
                                 searchBar.heightAnchor.constraint(equalToConstant: Layout.searchBoxHeight)]
        
        let buttonConstraints = [inviteButton.heightAnchor.constraint(equalToConstant: Layout.inviteButtonHeight),
                                 inviteButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.inviteButtonMinimumWidth),
                                 inviteButton.trailingAnchor.constraint(equalTo: tableViewAllContacts.trailingAnchor, constant: -Metrics.bigMargin),
                                 inviteButton.leadingAnchor.constraint(equalTo: tableViewAllContacts.leadingAnchor, constant: Metrics.bigMargin),
                                 inviteButton.bottomAnchor.constraint(equalTo: keyboardView.topAnchor, constant: -Metrics.veryBigMargin)]
        
        NSLayoutConstraint.activate([searchConstraints,
                                     tableViewSearchResultsConstraints,
                                     tableViewAllContactsConstraints,
                                     buttonConstraints].flatMap { $0 })
    }
    
    fileprivate func update(with status: StatusInviteSMSContactsStatus) {
        switch status {
        case .loading:
            emptyState.removeFromSuperview()
            tableViewAllContacts.isHidden = false
            tableViewSearchResults.isHidden = false
        case .data:
            emptyState.removeFromSuperview()
            tableViewAllContacts.isHidden = false
            tableViewSearchResults.isHidden = true
            tableViewAllContacts.reloadData()
        case .filtering:
            emptyState.removeFromSuperview()
            tableViewAllContacts.isHidden = true
            tableViewSearchResults.isHidden = false
            tableViewSearchResults.reloadData()
        case .error:
            let block: () -> () = { self.viewModel.requestContactPermissions() }
            let action = UIAction(interface: .button(R.Strings.commonErrorListRetryButton,
                                                     .primary(fontSize: .medium)),
                                  action: block )
            emptyState.populate(message: R.Strings.commonErrorGenericBody,
                                action: action)
            view.addSubviewForAutoLayout(emptyState)
            constraintViewToSafeRootView(emptyState)
        case .needPermissions:
            let block: () -> () = { self.openSettings() }
            let action = UIAction(interface: .button(R.Strings.affiliationInviteSmsGoSettingsButton,
                                                     .primary(fontSize: .medium)),
                                  action: block )
            emptyState.populate(message: R.Strings.affiliationInviteSmsContactsNeedPermissions,
                                action: action)
            view.addSubviewForAutoLayout(emptyState)
            constraintViewToSafeRootView(emptyState)
        case .empty:
            emptyState.populate(message:R.Strings.affiliationInviteSmsContactsEmptyState,
                                action: nil)
            view.addSubviewForAutoLayout(emptyState)
            constraintViewToSafeRootView(emptyState)
        }
    }
    
    private func setAccessibilityIds() {
    }
    
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.openURL(settingsUrl)
    }
    
    
    // MARK: - Button actions
    @objc private func doneButtonTapped() {
        searchBar.resignFirstResponder()
        viewModel.smsText().retrieveSMSShareText { [weak self] message in
            self?.sendSMS(recipients: self?.viewModel.contactsSelected, text:message)
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === tableViewAllContacts {
            guard let cell = tableView.dequeue(type: AffiliationInviteSMSContactsCell.self,
                                               for: indexPath) else {
                                                return UITableViewCell()
            }
            let state = viewModel.stateFor(contactInfo: datasourceAllContacts[indexPath.row])
            let cellViewModel = AffiliationInviteSMSContactsCellViewModel(content: datasourceAllContacts[indexPath.row], isFirstWithLetter: viewModel.isFirstLetter(position: indexPath.row), state: state)
            cell.setup(withViewModel: cellViewModel)
            updateTableViewSelectionState(cellState: cellViewModel.state, atIndexPath: indexPath, tableView: tableView)
            return cell
        } else {
            guard let cell = tableView.dequeue(type: AffiliationInviteSMSContactsCell.self,
                                               for: indexPath) else {
                                                return UITableViewCell()
            }
            let state = viewModel.stateFor(contactInfo: datasourceSearchResults[indexPath.row])
            let cellViewModel = AffiliationInviteSMSContactsCellViewModel(content: datasourceSearchResults[indexPath.row], isFirstWithLetter: false, state: state)
            cell.setup(withViewModel: cellViewModel)
            updateTableViewSelectionState(cellState: cellViewModel.state, atIndexPath: indexPath, tableView: tableView)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === tableViewAllContacts {
            return datasourceAllContacts.count
        } else {
            return datasourceSearchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeue(type: AffiliationInviteSMSContactsCell.self,
                                           for: indexPath) else { return }
        if tableView === tableViewAllContacts {
            cell.updateState(state: .selected)
            viewModel.cellSelected(contactInfo: datasourceAllContacts[indexPath.row])
            tableView.reloadData()
        } else {
            cell.updateState(state: .selected)
            viewModel.cellSelected(contactInfo: datasourceSearchResults[indexPath.row])
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeue(type: AffiliationInviteSMSContactsCell.self,
                                           for: indexPath) else { return }
        if tableView === tableViewAllContacts {
            cell.updateState(state: .deselected)
            viewModel.cellDeselected(contactInfo: datasourceAllContacts[indexPath.row])
            tableView.reloadData()
        } else {
            cell.updateState(state: .deselected)
            viewModel.cellDeselected(contactInfo: datasourceSearchResults[indexPath.row])
            tableView.reloadData()
        }
    }
    
    private func updateTableViewSelectionState(cellState state: AffiliationInviteSMSContactsCellState,
                                               atIndexPath indexPath: IndexPath, tableView: UITableView) {
        switch state {
        case .selected:
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        case .deselected:
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    
    // MARK: - Search Bar
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.clearTextFilter()
        } else {
            viewModel.didFilter(withText: searchText)
        }
        reloadView()
    }
    
    private func reloadView() {
        let selectedIndexPaths = tableViewAllContacts.indexPathsForSelectedRows
        tableViewAllContacts.reloadData()
        selectedIndexPaths?.forEach({ indexPath in
            tableViewAllContacts.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension AffiliationInviteSMSContactsViewController: MFMessageComposeViewControllerDelegate {
    
    func sendSMS(recipients: [ContactInfo]?, text: String) {
        guard recipients != nil else { return }
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = text
            var arrayPhones: [String] = []
            recipients?.forEach {
                arrayPhones.append($0.phoneNumber)
            }
            controller.recipients = arrayPhones
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        let callbackMessage: String
        switch result {
        case .cancelled:
            callbackMessage = R.Strings.affiliationInviteSmsMessageCancel
        case .sent:
            callbackMessage = R.Strings.affiliationInviteSmsMessageSent
        case .failed:
            callbackMessage = R.Strings.affiliationInviteSmsMessageError
        }
        self.dismiss(animated: true, completion: nil)
        searchBar.resignFirstResponder()
        self.showAutoFadingOutMessageAlert(message: callbackMessage)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
        self.navigationController?.isNavigationBarHidden = false
    }
}
