//
//  ChatConversationsListViewController.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

final class ChatConversationsListViewController: BaseViewController, ChatConversationsListViewModelDelegate {

    private let viewModel: ChatConversationsListViewModel
    private let conversationsListView = ChatConversationsListView()
    
    private let optionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "ic_more_options"), for: .normal)
        return button
    }()
    
    // MARK: Lifecycle
    
    init(viewModel: ChatConversationsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true
        self.viewModel.delegate = self
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
        optionsButton.addTarget(self, action: #selector(optionsButtonPressed), for: .touchUpInside)
        setNavigationBarRightButtons([optionsButton])
    }
    
    // MARK: Actions
    
    @objc private func optionsButtonPressed() {
        viewModel.optionsButtonPressed()
    }
}
