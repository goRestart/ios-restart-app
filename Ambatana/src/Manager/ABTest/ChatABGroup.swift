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
        static let markAllConversationsAsRead = "20180508MarkAllConversationsAsRead"
        static let chatNorris = "20180319ChatNorris"
        static let chatConversationsListWithoutTabs = "20180509ChatConversationsListWithoutTabs"
    }

    let showInactiveConversations: LeanplumABVariable<Bool>
    let showChatSafetyTips: LeanplumABVariable<Bool>
    let userIsTyping: LeanplumABVariable<Int>
    let markAllConversationsAsRead: LeanplumABVariable<Int>
    let chatNorris: LeanplumABVariable<Int>
    let chatConversationsListWithoutTabs: LeanplumABVariable<Int>

    let group: ABGroup = .chat
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(showInactiveConversations: LeanplumABVariable<Bool>,
         showChatSafetyTips: LeanplumABVariable<Bool>,
         userIsTyping: LeanplumABVariable<Int>,
         markAllConversationsAsRead: LeanplumABVariable<Int>,
         chatNorris: LeanplumABVariable<Int>,
         chatConversationsListWithoutTabs: LeanplumABVariable<Int>) {
        self.showInactiveConversations = showInactiveConversations
        self.showChatSafetyTips = showChatSafetyTips
        self.userIsTyping = userIsTyping
        self.markAllConversationsAsRead = markAllConversationsAsRead
        self.chatNorris = chatNorris
        self.chatConversationsListWithoutTabs = chatConversationsListWithoutTabs

        intVariables.append(contentsOf: [userIsTyping,
                                         markAllConversationsAsRead,
                                         chatNorris,
                                         chatConversationsListWithoutTabs])

        boolVariables.append(contentsOf: [showInactiveConversations,
                                          showChatSafetyTips])
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
                           markAllConversationsAsRead: .makeInt(key: Keys.markAllConversationsAsRead,
                                                                 defaultValue: 0,
                                                                 groupType: .chat),
                           chatNorris: .makeInt(key: Keys.chatNorris,
                                                defaultValue: 0,
                                                groupType: .chat),
                           chatConversationsListWithoutTabs: .makeInt(key: Keys.chatConversationsListWithoutTabs,
                                                                     defaultValue: 0,
                                                                     groupType: .chat))
    }
}
