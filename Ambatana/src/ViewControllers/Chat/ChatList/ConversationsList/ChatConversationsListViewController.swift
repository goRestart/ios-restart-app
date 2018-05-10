//
//  ChatConversationsListViewController.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

final class ChatConversationsListViewController: BaseViewController {
    
    private let viewModel: ChatConversationsListViewModel
    private let conversationsListView = ChatConversationsListView()
    
    private let optionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "ic_more_options"), for: .normal)
        button.addTarget(self, action: #selector(optionsButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: Lifecycle
    
    init(viewModel: ChatConversationsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Navigation Bar
    
    private func setupNavigationBar() {
        setNavigationBarRightButtons([optionsButton])
    }
    
    // MARK: Actions
    
    @objc private func optionsButtonPressed() {
        viewModel.openBlockedUsers()
    }
}
