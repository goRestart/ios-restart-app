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
    UITableViewDataSource,
UITableViewDelegate  {
    
    private let viewModel: ChatInactiveConversationsListViewModel
    private let disposeBag = DisposeBag()
    
    private var editButton: UIBarButtonItem?
    
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
        }
    }
    
    init(viewModel: ChatInactiveConversationsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ChatInactiveConversationsListView")
        viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
        
        viewModel.retrieveFirstPage()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        setFooterHidden(!editing, animated: true)
        
        if viewModel.active {
            tabBarController?.setTabBarHidden(editing, animated: true)
        }
        viewModel.editing.value = editing
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = UIColor.listBackgroundColor
        setNavBarTitle(LGLocalizedString.chatInactiveListTitle)
        
        emptyView.backgroundColor = UIColor.listBackgroundColor
        refreshControl.addTarget(self, action: #selector(refresh),
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
        footerButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        
        bottomInset = tabBarBottomInset
        setFooterHidden(true, animated: false)
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        editButton = UIBarButtonItem(title: LGLocalizedString.chatListDelete,
                                     style: .plain,
                                     target: self,
                                     action: #selector(editButtonPressed))
        navigationItem.setRightBarButton(editButton, animated: false)
    }
    
    func updateUI() {
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
    
    private func setupRx() {
        viewModel.objects.asObservable()
            .subscribeNext { [weak self] change in
                self?.updateUI()
            }
            .disposed(by: disposeBag)

        viewModel.editButtonText.asObservable()
            .subscribeNext { [weak self] text in
                self?.editButton?.title = text
            }
            .disposed(by: disposeBag)
        
        viewModel.editButtonEnabled.asObservable()
            .subscribeNext { [weak self] enabled in
                self?.editButton?.isEnabled = enabled
            }
            .disposed(by: disposeBag)
        
        viewModel.deleteButtonEnabled.asObservable()
            .subscribeNext { [weak self] enabled in
                self?.footerButton.isEnabled = enabled
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    @objc func editButtonPressed() {
        setEditing(!isEditing, animated: true)
    }
    
    @objc func refresh() {
        activityIndicator.startAnimating()
        viewModel.refresh { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    @objc func deleteButtonPressed() {
        viewModel.deleteButtonPressed()
        updateUI()
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

    // MARK: - UITableViewDelegate & UITableViewDataSource

    func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        guard let chatData = viewModel.conversationDataAtIndex(indexPath.row)
            else { return UITableViewCell() }
        guard let chatCell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reusableID,
                                                           for: indexPath) as? ConversationCell
            else { return UITableViewCell() }
        
        chatCell.tag = (indexPath as NSIndexPath).hash // used for cell reuse on "setupCellWithData"
        chatCell.setupCellWithData(chatData, indexPath: indexPath)
        
        let isSelected = viewModel.isConversationSelected(index: indexPath.row)
        if isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return chatCell
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
        viewModel.selectConversation(index: indexPath.row, editing: tableView.isEditing)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        viewModel.deselectConversation(index: indexPath.row, editing: tableView.isEditing)
    }
    
    // MARK: - ChatInactiveConversationsListViewModelDelegate
    
    func shouldUpdateStatus() {
        updateUI()
    }
    
    func didStartRetrievingObjectList() {
        updateUI()
    }
    
    func didFailRetrievingObjectList(_ page: Int) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func didSucceedRetrievingObjectList(_ page: Int) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    func didFailArchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        dismissLoadingMessageAlert { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.chatListArchiveErrorMultiple)
        }
    }
    
    func didSucceedArchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        dismissLoadingMessageAlert { [weak self] in
            self?.setEditing(false, animated: true)
        }
    }
    
    func didFailUnarchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        dismissLoadingMessageAlert { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.chatListUnarchiveErrorMultiple)
        }
    }
    
    func didSucceedUnarchivingChats(viewModel: ChatInactiveConversationsListViewModel) {
        dismissLoadingMessageAlert { [weak self] in
            self?.setEditing(false, animated: true)
        }
    }
    
    func shouldShowDeleteConfirmation(title: String,
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
}
