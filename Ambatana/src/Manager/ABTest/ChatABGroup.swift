//
//  ABChat.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct ChatABGroup: ABGroupType {
    private struct Keys {
        static let showInactiveConversations = "20180206ShowInactiveConversations"
        static let showChatSafetyTips = "20180226ShowChatSafetyTips"
        static let userIsTyping = "20180305UserIsTyping"
        static let markAllConversationsAsRead = "20180321MarkAllConversationsAsRead"
        static let chatNorris = "20180319ChatNorris"
    }

    let showInactiveConversations: LeanplumABVariable<Bool>
    let showChatSafetyTips: LeanplumABVariable<Bool>
    let userIsTyping: LeanplumABVariable<Int>
    let markAllConversationsAsRead: LeanplumABVariable<Bool>
    let chatNorris: LeanplumABVariable<Int>

    let group: ABGroup = .chat
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(showInactiveConversations: LeanplumABVariable<Bool>,
         showChatSafetyTips: LeanplumABVariable<Bool>,
         userIsTyping: LeanplumABVariable<Int>,
         markAllConversationsAsRead: LeanplumABVariable<Bool>,
         chatNorris: LeanplumABVariable<Int>) {
        self.showInactiveConversations = showInactiveConversations
        self.showChatSafetyTips = showChatSafetyTips
        self.userIsTyping = userIsTyping
        self.markAllConversationsAsRead = markAllConversationsAsRead
        self.chatNorris = chatNorris

        intVariables.append(contentsOf: [userIsTyping,
                                         chatNorris])

        boolVariables.append(contentsOf: [showInactiveConversations,
                                          showChatSafetyTips,
                                          markAllConversationsAsRead])
    }

    static func make() -> ChatABGroup {
        return ChatABGroup(showInactiveConversations: .makeBool(key: Keys.showInactiveConversations,
                                                                defaultValue: false,
                                                                groupType: .chat),
                           showChatSafetyTips: .makeBool(key: Keys.showChatSafetyTips,
                                                         defaultValue: false,
                                                         groupType: .chat),
                           userIsTyping: .makeInt(key: Keys.userIsTyping,
                                                  defaultValue: 0,
                                                  groupType: .chat),
                           markAllConversationsAsRead: .makeBool(key: Keys.markAllConversationsAsRead,
                                                                 defaultValue: false,
                                                                 groupType: .chat),
                           chatNorris: .makeInt(key: Keys.chatNorris,
                                                defaultValue: 0,
                                                groupType: .chat))
    }
}
