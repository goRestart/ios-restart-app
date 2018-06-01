//
//  ChatConversationsListView.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import RxSwift

final class ChatConversationsListView: UIView {
    
    struct Time {
        static let animationDuration: TimeInterval = 0.1
    }
    
    struct Layout {
        static let rowHeight: CGFloat = 80
    }
    
    private let statusView = ChatStatusView()
    private let tableView = UITableView()
    private let emptyView = LGEmptyView()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private let refreshControl = UIRefreshControl()
    
    var refreshControlBlock: (() -> Void)?
    var rx_tableView: Reactive<UITableView> {
        return tableView.rx
    }
    var indexPathsForVisibleRows: [IndexPath]? {
        return tableView.indexPathsForVisibleRows
    }
    
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setupUI() {
        backgroundColor = UIColor.listBackgroundColor
        emptyView.alpha = 0
        setupTableView()
        addRefreshControl()
    }
    
    private func setupTableView() {
        tableView.register(ChatUserConversationCell.self, forCellReuseIdentifier: ChatUserConversationCell.reusableID)
        tableView.alpha = 0
        tableView.rowHeight = Layout.rowHeight
        tableView.separatorStyle = .singleLine
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
    }
    
    private func setupConstraints() {
        addSubviewForAutoLayout(activityIndicatorView)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: activityIndicatorView.centerXAnchor),
            centerYAnchor.constraint(equalTo: activityIndicatorView.centerYAnchor)
            ])
        
        addSubviewForAutoLayout(emptyView)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: emptyView.topAnchor),
            bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),
            leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            trailingAnchor.constraint(equalTo: emptyView.trailingAnchor)
            ])
        
        addSubviewForAutoLayout(tableView)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: tableView.topAnchor),
            bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
            ])
    }

    private func addRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    // MARK: Actions
    
    @objc private func refresh() {
        refreshControlBlock?()
    }
    
    func endRefresh() {
        refreshControl.endRefreshing()
    }
    
    func switchEditMode(isEditing: Bool) {
        tableView.isEditing = isEditing
    }
    
    // MARK: View states
    
    func showEmptyView(with emptyViewModel: LGEmptyViewModel) {
        emptyView.setupWithModel(emptyViewModel)
        tableView.animateTo(alpha: 0, duration: Time.animationDuration)
        emptyView.animateTo(alpha: 1, duration: Time.animationDuration) { [weak self] finished in
            self?.activityIndicatorView.stopAnimating()
        }
    }
    
    func showTableView() {
        emptyView.animateTo(alpha: 0, duration: Time.animationDuration)
        tableView.animateTo(alpha: 1, duration: Time.animationDuration) { [weak self] finished in
            self?.activityIndicatorView.stopAnimating()
        }
    }
    
    func showActivityIndicator() {
        emptyView.animateTo(alpha: 0, duration: Time.animationDuration)
        tableView.animateTo(alpha: 0, duration: Time.animationDuration)
        activityIndicatorView.startAnimating()
    }
}
