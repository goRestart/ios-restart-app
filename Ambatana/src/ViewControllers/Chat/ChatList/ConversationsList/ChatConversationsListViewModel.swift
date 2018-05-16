//
//  ChatConversationsListViewModel.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatConversationsListViewModelDelegate: BaseViewModelDelegate {}

final class ChatConversationsListViewModel: BaseViewModel {
    
    weak var navigator: ChatsTabNavigator?
    private let chatRepository: ChatRepository
    private let featureFlags: FeatureFlaggeable
    weak var delegate: ChatConversationsListViewModelDelegate?

    private var shouldShowInactiveConversations: Bool {
        return featureFlags.showInactiveConversations
    }
    private var inactiveConversationsCount: Int? {
        return chatRepository.inactiveConversationsCount.value
    }

    convenience override init() {
        self.init(chatRepository: Core.chatRepository, featureFlags: FeatureFlags.sharedInstance)
    }

    init(chatRepository: ChatRepository, featureFlags: FeatureFlaggeable) {
        self.chatRepository = chatRepository
        self.featureFlags = featureFlags
        super.init()
    }


    // MARK: Navigation

    func optionsButtonPressed() {
        var actions: [UIAction] = []

        if shouldShowInactiveConversations {
            var buttonText: String = LGLocalizedString.chatInactiveConversationsButton
            if let inactiveCount = inactiveConversationsCount, inactiveCount > 0 {
                buttonText = buttonText + " (\(inactiveCount))"
            }
            actions.append(UIAction(interface: UIActionInterface.text(buttonText),
                                    action: { [weak self] in
                                        self?.openInactiveConversations()
            }))
        }

        actions.append(UIAction(interface: UIActionInterface.text(LGLocalizedString.chatListBlockedUsersTitle),
                                action: { [weak self] in
                                    self?.openBlockedUsers()
        }))

        delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
    }

    func openInactiveConversations() {
        navigator?.openInactiveConversations()
    }

    func openBlockedUsers() {
        navigator?.openBlockedUsers()
    }
}
