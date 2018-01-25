//
//  ChatInactiveConversationDetailsViewController.swift
//  LetGo
//
//  Created by Nestor on 18/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class ChatInactiveConversationDetailsViewController: BaseViewController {

    private let viewModel: ChatInactiveConversationDetailsViewModel
    
    init(viewModel: ChatInactiveConversationDetailsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
