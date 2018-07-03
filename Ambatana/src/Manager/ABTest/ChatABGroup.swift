import Foundation

struct ChatABGroup: ABGroupType {
    private struct Keys {
        static let showInactiveConversations = "20180206ShowInactiveConversations"
        static let showChatSafetyTips = "20180226ShowChatSafetyTips"
        static let userIsTyping = "20180305UserIsTyping"
        static let chatNorris = "20180319ChatNorris"
        static let chatConversationsListWithoutTabs = "20180509ChatConversationsListWithoutTabs"
        static let showChatConnectionStatusBar = "20180621ShowChatConnectionStatusBar"
        static let showChatHeaderWithoutListingForAssistant = "20180629ShowChatHeaderWithoutListingForAssistant"
    }

    let showInactiveConversations: LeanplumABVariable<Bool>
    let showChatSafetyTips: LeanplumABVariable<Bool>
    let userIsTyping: LeanplumABVariable<Int>
    let chatNorris: LeanplumABVariable<Int>
    let chatConversationsListWithoutTabs: LeanplumABVariable<Int>
    let showChatConnectionStatusBar: LeanplumABVariable<Int>
    let showChatHeaderWithoutListingForAssistant: LeanplumABVariable<Bool>

    let group: ABGroup = .chat
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(showInactiveConversations: LeanplumABVariable<Bool>,
         showChatSafetyTips: LeanplumABVariable<Bool>,
         userIsTyping: LeanplumABVariable<Int>,
         chatNorris: LeanplumABVariable<Int>,
         chatConversationsListWithoutTabs: LeanplumABVariable<Int>,
         showChatConnectionStatusBar: LeanplumABVariable<Int>,
         showChatHeaderWithoutListingForAssistant: LeanplumABVariable<Bool>) {
        self.showInactiveConversations = showInactiveConversations
        self.showChatSafetyTips = showChatSafetyTips
        self.userIsTyping = userIsTyping
        self.chatNorris = chatNorris
        self.chatConversationsListWithoutTabs = chatConversationsListWithoutTabs
        self.showChatConnectionStatusBar = showChatConnectionStatusBar
        self.showChatHeaderWithoutListingForAssistant = showChatHeaderWithoutListingForAssistant

        intVariables.append(contentsOf: [userIsTyping,
                                         chatNorris,
                                         chatConversationsListWithoutTabs,
                                         showChatConnectionStatusBar])

        boolVariables.append(contentsOf: [showInactiveConversations,
                                          showChatSafetyTips,
                                          showChatHeaderWithoutListingForAssistant])
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
                           chatNorris: .makeInt(key: Keys.chatNorris,
                                                defaultValue: 0,
                                                groupType: .chat),
                           chatConversationsListWithoutTabs: .makeInt(key: Keys.chatConversationsListWithoutTabs,
                                                                      defaultValue: 0,
                                                                      groupType: .chat),
                           showChatConnectionStatusBar: .makeInt(key: Keys.showChatConnectionStatusBar,
                                                                 defaultValue: 0,
                                                                 groupType: .chat),
                           showChatHeaderWithoutListingForAssistant: .makeBool(key: Keys.showChatHeaderWithoutListingForAssistant,
                                                                               defaultValue: false,
                                                                               groupType: .chat)

        )
    }
}
