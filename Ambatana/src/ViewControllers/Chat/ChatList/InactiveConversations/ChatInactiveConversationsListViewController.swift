//
//  ChatInactiveConversationsListViewController.swift
//  LetGo
//
//  Created by Nestor on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class ChatInactiveConversationsListViewController:
    BaseViewController,
    ChatInactiveConversationsListViewModelDelegate,
    ScrollableToTop,
    UITableViewDataSource,
UITableViewDelegate  {
    
    private let viewModel: ChatInactiveConversationsListViewModel
    var editButton: UIBarButtonItem?
    private let disposeBag = DisposeBag()
    
    private let tabBarBottomInset: CGFloat = 49
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var footerButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emptyView: LGEmptyView!
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableViewBottomInset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottomInset: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomInset: NSLayoutConstraint!
    
    var bottomInset: CGFloat = 0 {
        didSet {
            tableView.contentInset.bottom = bottomInset
            activityIndicatorBottomInset.constant = bottomInset/2
            emptyViewBottomInset.constant = bottomInset
            view.updateConstraints()
        }
    }
    
    init(viewModel: ChatInactiveConversationsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ChatInactiveConversationsListView")
        viewModel.delegate = self
        
        self.editButton = UIBarButtonItem(title: LGLocalizedString.chatListDelete, style: .plain, target: self,
                                          action: #selector(edit))
        
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true
        
//        for index in 0..<viewModel.chatListsCount {
//            let page: ChatListView
//
//            guard let pageVM = viewModel.chatListViewModelForTabAtIndex(index) else { continue }
//            page = ChatListView(viewModel: pageVM)
//            page.tableView.accessibilityId = viewModel.accessibilityIdentifierForTableViewAtIndex(index)
//            page.footerButton.accessibilityId = .chatListViewFooterButton
//            page.chatGroupedListViewDelegate = self
//            page.delegate = self
//            pages.append(page)
//        }
//
//        let pageVM = viewModel.blockedUsersListViewModel
//        let page = BlockedUsersListView(viewModel: pageVM)
//        page.chatGroupedListViewDelegate = self
//        page.blockedUsersListViewDelegate = self
//        pages.append(page)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
        
        // TODO: here or in did appear?
        viewModel.retrieveFirstPage()
        scrollToTop()
    }
    
    // MARK: - UI
    
    func setupUI() {
        view.backgroundColor = UIColor.listBackgroundColor
        setNavBarTitle(LGLocalizedString.chatInactiveListTitle)
        
//        Bundle.main.loadNibNamed("ChatGroupedListView", owner: self, options: nil)
//        contentView.frame = view.bounds
//        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        contentView.backgroundColor = UIColor.listBackgroundColor
//        view.addSubview(contentView)
        
        // Empty view
        emptyView.backgroundColor = UIColor.listBackgroundColor
        refreshControl.addTarget(self, action: #selector(ChatGroupedListView.refresh),
                                 for: UIControlEvents.valueChanged)
        
        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ConversationCell.reusableID)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Footer
        footerButton.setStyle(.primary(fontSize: .medium))
        footerButton.isEnabled = false
        footerButton.setTitle(LGLocalizedString.chatListDelete, for: .normal)
        footerButton.addTarget(self, action: #selector(ChatListView.deleteButtonPressed), for: .touchUpInside)
        
        bottomInset = tabBarBottomInset
        setFooterHidden(true, animated: false)
    }
    
    func resetUI() {
        if viewModel.activityIndicatorAnimating {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        if let emptyViewModel = viewModel.emptyViewModel {
            emptyView.setupWithModel(emptyViewModel)
        }
        emptyView.isHidden = viewModel.emptyViewHidden
        tableView.isHidden = viewModel.tableViewHidden
        tableView.reloadData()
    }
    
    func setupRx() {
        viewModel.objects.asObservable().subscribeNext { [weak self] change in
            self?.tableView.reloadData()
            }.disposed(by: disposeBag)
        
//        viewModel.shouldScrollToTop.subscribeNext { [weak self] shouldScrollToTop in
//            guard let tableView = self?.tableView, tableView.numberOfRows(inSection: 0) > 0 else { return }
//            let indexPath = IndexPath(row: 0, section: 0)
//            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//            }.disposed(by: disposeBag)
        
        setupRxNavBarBindings()
    }
    
    private func setupRxNavBarBindings() {
        viewModel.editButtonText.asObservable().subscribeNext { [weak self] editButtonText in
            guard let strongSelf = self else { return }
            
            let editButton = UIBarButtonItem(title: editButtonText,
                                             style: .plain,
                                             target: strongSelf,
                                             action: #selector(strongSelf.edit))
            editButton.isEnabled = strongSelf.viewModel.editButtonEnabled.value
            strongSelf.editButton = editButton
            strongSelf.navigationItem.setRightBarButton(editButton, animated: false)
        }.disposed(by: disposeBag)
        
        viewModel.editButtonEnabled.asObservable().subscribeNext { [weak self] enabled in
            guard let strongSelf = self else { return }
            
            // If becomes hidden then end editing
            let wasEnabled = strongSelf.navigationItem.rightBarButtonItem?.isEnabled ?? false
            if wasEnabled && !enabled {
                self?.setEditing(false, animated: true)
            }
            
            strongSelf.editButton?.isEnabled = enabled
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc func edit() {
        setEditing(!isEditing, animated: true)
    }
    
    @objc func refresh() {
        viewModel.refresh(completion: nil)
    }
    
    @objc func clear() {
        viewModel.clear()
        tableView.reloadData()
    }
    
    func setFooterHidden(_ hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {
        let visibilityOK = ( footerViewBottom.constant < 0 ) == hidden
        guard !visibilityOK else { return }
        
        if !hidden, let selectedRows = tableView.indexPathsForSelectedRows?.count {
            footerButton.isEnabled = selectedRows > 0
        }
        bottomInset = hidden ? tabBarBottomInset : 0
        footerViewBottom.constant = hidden ? -footerView.frame.height : 0
        
        let duration : TimeInterval = (animated ? TimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            }, completion: completion)
    }
    
    // MARK: - ScrollableToTop
    
    func scrollToTop() {
        guard let tableView = tableView else { return }
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource

    func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        // Implement in subclasses
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRowAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.setCurrentIndex(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAtIndex(indexPath.row, editing: tableView.isEditing)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didDeselectRowAtIndex(indexPath.row, editing: tableView.isEditing)
    }
    
    func didSelectRowAtIndex(_ index: Int, editing: Bool) {
        if editing, let selectedRows = tableView.indexPathsForSelectedRows?.count {
            footerButton.isEnabled = selectedRows > 0
        } else {
            footerButton.isEnabled = false
        }
    }
    
    func didDeselectRowAtIndex(_ index: Int, editing: Bool) {
        if editing, let selectedRows = tableView.indexPathsForSelectedRows?.count{
            footerButton.isEnabled = selectedRows > 0
        } else {
            footerButton.isEnabled = false
        }
    }
    
    // MARK: - ChatGroupedListViewModelDelegate

    func chatGroupedListViewModelSetEditing(_ editing: Bool) {
        setEditing(editing)
    }
    
    func shouldUpdateStatus() {
        //        chatGroupedListViewDelegate?.chatGroupedListViewShouldUpdateInfoIndicators()
        //        resetUI()
    }
    
    func setEditing(_ editing: Bool) {
        tableView.setEditing(editing, animated: true)
        setFooterHidden(!editing, animated: true)
    }
    
    func didStartRetrievingObjectList() {
        
    }
    
    func didFailRetrievingObjectList(_ page: Int) {
        refreshControl.endRefreshing()
    }
    
    func didSucceedRetrievingObjectList(_ page: Int) {
        refreshControl.endRefreshing()
    }
    
    func didFailArchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        viewModel.refresh { [weak self] in
            self?.didFinishArchiving(withMessage: LGLocalizedString.chatListArchiveErrorMultiple)
        }
    }
    
    func didSucceedArchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        viewModel.refresh { [weak self] in
            self?.didFinishArchiving(withMessage: nil)
        }
    }
    
    func didFailUnarchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        viewModel.refresh { [weak self] in
            self?.didFinishUnarchiving(withMessage: LGLocalizedString.chatListUnarchiveErrorMultiple)
        }
    }
    
    func didSucceedUnarchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        viewModel.refresh { [weak self] in
            self?.didFinishUnarchiving(withMessage: nil)
        }
    }
    
    func viewModel(viewModel: ChatInactiveConversationsListViewModel,
                   showDeleteConfirmationWithTitle title: String,
                   message: String,
                   cancelText: String,
                   actionText: String,
                   action: @escaping () -> ()) {
        showDeleteConfirmation(withTitle: title,
            message: message,
            cancelText: cancelText,
            actionText: actionText) { [weak self] in
                self?.didStartArchiving()
                action()
        }
    }
    
    
    ////
    
    
    // MARK: - ChatListViewDelegate
    
    func showDeleteConfirmation(withTitle title: String,
                                message: String,
                                cancelText: String,
                                actionText: String,
                                action: @escaping () -> ()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        let archiveAction = UIAlertAction(title: actionText, style: .destructive) { (_) -> Void in
            action()
        }
        alert.addAction(cancelAction)
        alert.addAction(archiveAction)
        present(alert, animated: true, completion: nil)
    }
    
    func didStartArchiving() {
        showLoadingMessageAlert()
    }
    
    func didFinishArchiving(withMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }
    
    func didFinishUnarchiving(withMessage message: String?) {
        dismissLoadingMessageAlert { [weak self] in
            if let message = message {
                self?.showAutoFadingOutMessageAlert(message)
            } else {
                self?.setEditing(false, animated: true)
            }
        }
    }
}
