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
    @IBOutlet weak var footerButton: LetgoButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emptyView: LGEmptyView!
    
    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var activityIndicatorBottomInset: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomInset: NSLayoutConstraint!
    
    var bottomInset: CGFloat = 0 {
        didSet {
            activityIndicatorBottomInset.constant = bottomInset/2
            emptyViewBottomInset.constant = bottomInset
        }
    }
    
    // MARK: - Lifecycle
    
    init(viewModel: ChatInactiveConversationsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ChatInactiveConversationsListView")
        edgesForExtendedLayout = []
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
        
        viewModel.delegate = self
        viewModel.retrieveFirstPage()
    }
    
    deinit {
        viewModel.clean()
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
    
    private func setFooterHidden(_ hidden: Bool, animated: Bool, completion: ((Bool) -> (Void))? = nil) {
        let visibilityOK = ( footerViewBottom.constant < 0 ) == hidden
        guard !visibilityOK else { return }
        
        footerButton.isEnabled = !hidden && (tableView.indexPathsForSelectedRows?.count ?? 0) > 0
        bottomInset = hidden ? tabBarBottomInset : 0
        footerViewBottom.constant = hidden ? -footerView.frame.height : 0
        
        let duration : TimeInterval = (animated ? TimeInterval(UINavigationControllerHideShowBarDuration) : 0.0)
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.view.layoutIfNeeded()
            }, completion: completion)
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
    
    private func updateUI() {
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
        viewModel.status.asObservable()
            .subscribeNext { [weak self] _ in
                self?.updateUI()
            }
            .disposed(by: disposeBag)
        
        viewModel.rx_objectCount.asObservable()
            .subscribeNext { [weak self] _ in
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
        viewModel.retrieveFirstPage()
    }
    
    @objc func deleteButtonPressed() {
        viewModel.deleteButtonPressed()
    }

    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.objectCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func didStartRetrievingObjectList() {
        
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
    
    func didFailArchivingChats() {
        dismissLoadingMessageAlert { [weak self] in
            self?.showAutoFadingOutMessageAlert(message: LGLocalizedString.chatListArchiveErrorMultiple)
        }
    }
    
    func didSucceedArchivingChats() {
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
