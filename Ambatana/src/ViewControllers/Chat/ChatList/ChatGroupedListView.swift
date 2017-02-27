//
//  ChatGroupedListView.swift
//  LetGo
//
//  Created by Dídac on 15/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ChatGroupedListViewDelegate: class {
    func chatGroupedListViewShouldUpdateInfoIndicators()
}

class ChatGroupedListView: BaseView, ChatGroupedListViewModelDelegate, ScrollableToTop, UITableViewDataSource,
                              UITableViewDelegate {

    // Constants
    private let tabBarBottomInset: CGFloat = 49

    // UI
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var footerButton: UIButton!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var emptyView: LGEmptyView!

    var refreshControl = UIRefreshControl()

    
    // > Insets
    @IBOutlet weak var tableViewBottomInset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorBottomInset: NSLayoutConstraint!
    @IBOutlet weak var emptyViewBottomInset: NSLayoutConstraint!

    var bottomInset: CGFloat = 0 {
        didSet {
            tableView.contentInset.bottom = bottomInset
            activityIndicatorBottomInset.constant = bottomInset/2
            emptyViewBottomInset.constant = bottomInset
            updateConstraints()
        }
    }

    // Data
    private var viewModel: ChatGroupedListViewModel
    weak var chatGroupedListViewDelegate: ChatGroupedListViewDelegate?

    private let sessionManager: SessionManager

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init<T: BaseViewModel>(viewModel: T) where T: ChatGroupedListViewModel {
        self.init(viewModel: viewModel, sessionManager: Core.sessionManager, frame: CGRect.zero)
    }

    init<T: BaseViewModel>(viewModel: T, sessionManager: SessionManager, frame: CGRect) where T: ChatGroupedListViewModel {
        self.viewModel = viewModel
        self.sessionManager = sessionManager
        super.init(viewModel: viewModel, frame: frame)

        viewModel.chatGroupedDelegate = self
        setupUI()
        resetUI()
    }

    init?<T: BaseViewModel>(viewModel: T, sessionManager: SessionManager, coder aDecoder: NSCoder) where T: ChatGroupedListViewModel {
        self.viewModel = viewModel
        self.sessionManager = sessionManager
        super.init(viewModel: viewModel, coder: aDecoder)

        viewModel.chatGroupedDelegate = self
        setupUI()
        resetUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    internal override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            sessionManager.sessionEvents.filter { $0.isLogout }.bindNext { [weak self] _ in
                self?.clear()
            }.addDisposableTo(disposeBag)
            
            viewModel.retrieveFirstPage()
        }
    }


    // MARK: - Public Methods

    dynamic func refresh() {
        viewModel.refresh(completion: nil)
    }

    dynamic func clear() {
        viewModel.clear()
        tableView.reloadData()
    }

    func setEditing(_ editing: Bool) {
        tableView.setEditing(editing, animated: true)
        setFooterHidden(!editing, animated: true)
    }


    // MARK: - UITableViewDataSource

    func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        // Implement in subclasses
        return UITableViewCell()
    }


    // MARK: - UITableViewDelegate

    func didSelectRowAtIndex(_ index: Int, editing: Bool) {
        if editing, let selectedRows = tableView.indexPathsForSelectedRows?.count {
            footerButton.isEnabled = selectedRows > 0
        }
    }

    func didDeselectRowAtIndex(_ index: Int, editing: Bool) {
        if editing, let selectedRows = tableView.indexPathsForSelectedRows?.count{
            footerButton.isEnabled = selectedRows > 0
        }
    }

    
    // MARK: - ChatGroupedListViewModelDelegate

    func chatGroupedListViewModelShouldUpdateStatus() {
        chatGroupedListViewDelegate?.chatGroupedListViewShouldUpdateInfoIndicators()
        resetUI()
    }

    func chatGroupedListViewModelSetEditing(_ editing: Bool) {
        setEditing(editing)
    }

    func chatGroupedListViewModelDidStartRetrievingObjectList() {

    }

    func chatGroupedListViewModelDidFailRetrievingObjectList(_ page: Int) {
        refreshControl.endRefreshing()
    }

    func chatGroupedListViewModelDidSucceedRetrievingObjectList(_ page: Int) {
        refreshControl.endRefreshing()
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        guard let tableView = tableView else { return }
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }


    // MARK: - UITableViewDelegate & DataSource methods

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


    // MARK: - Private Methods

    func setupUI() {
        // Load the view, and add it as Subview
        Bundle.main.loadNibNamed("ChatGroupedListView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.listBackgroundColor
        addSubview(contentView)

        // Empty view
        emptyView.backgroundColor = UIColor.listBackgroundColor
        refreshControl.addTarget(self, action: #selector(ChatGroupedListView.refresh),
                                 for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)

        // Footer
        footerButton.setStyle(.primary(fontSize: .medium))
        footerButton.isEnabled = false
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
            self?.layoutIfNeeded()
        }, completion: completion)
    }
}

