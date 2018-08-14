import Foundation

struct ChatABGroup: ABGroupType {
    private struct Keys {
        static let showInactiveConversations = "20180206ShowInactiveConversations"
        static let showChatSafetyTips = "20180226ShowChatSafetyTips"
        static let userIsTyping = "20180305UserIsTyping"
        static let chatNorris = "20180319ChatNorris"
        static let showChatConnectionStatusBar = "20180621ShowChatConnectionStatusBar"
        static let showChatHeaderWithoutListingForAssistant = "20180629ShowChatHeaderWithoutListingForAssistant"
        static let showChatHeaderWithoutUser = "20180702ShowChatHeaderWithoutUser"
        static let enableCTAMessageType = "20180716enableCTAMessageType"
        static let expressChatImprovement = "20180719ExpressChatImprovement"
        static let smartQuickAnswers = "20180806SmartQuickAnswers"
        static let openChatFromUserProfile = "20180807OpenChatFromUserProfile"
    }

    let showInactiveConversations: LeanplumABVariable<Bool>
    let showChatSafetyTips: LeanplumABVariable<Bool>
    let userIsTyping: LeanplumABVariable<Int>
    let chatNorris: LeanplumABVariable<Int>
    let showChatConnectionStatusBar: LeanplumABVariable<Int>
    let showChatHeaderWithoutListingForAssistant: LeanplumABVariable<Bool>
    let showChatHeaderWithoutUser: LeanplumABVariable<Bool>
    let enableCTAMessageType: LeanplumABVariable<Bool>
    let expressChatImprovement: LeanplumABVariable<Int>
    let smartQuickAnswers: LeanplumABVariable<Int>
    let openChatFromUserProfile: LeanplumABVariable<Int>

    let group: ABGroup = .chat
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(showInactiveConversations: LeanplumABVariable<Bool>,
         showChatSafetyTips: LeanplumABVariable<Bool>,
         userIsTyping: LeanplumABVariable<Int>,
         chatNorris: LeanplumABVariable<Int>,
         showChatConnectionStatusBar: LeanplumABVariable<Int>,
         showChatHeaderWithoutListingForAssistant: LeanplumABVariable<Bool>,
         showChatHeaderWithoutUser: LeanplumABVariable<Bool>,
         enableCTAMessageType: LeanplumABVariable<Bool>,
         expressChatImprovement: LeanplumABVariable<Int>,
         smartQuickAnswers: LeanplumABVariable<Int>,
         openChatFromUserProfile: LeanplumABVariable<Int>) {
        self.showInactiveConversations = showInactiveConversations
        self.showChatSafetyTips = showChatSafetyTips
        self.userIsTyping = userIsTyping
        self.chatNorris = chatNorris
        self.showChatConnectionStatusBar = showChatConnectionStatusBar
        self.showChatHeaderWithoutListingForAssistant = showChatHeaderWithoutListingForAssistant
        self.showChatHeaderWithoutUser = showChatHeaderWithoutUser
        self.enableCTAMessageType = enableCTAMessageType
        self.expressChatImprovement = expressChatImprovement
        self.smartQuickAnswers = smartQuickAnswers
        self.openChatFromUserProfile = openChatFromUserProfile

        intVariables.append(contentsOf: [userIsTyping,
                                         chatNorris,
                                         showChatConnectionStatusBar,
                                         expressChatImprovement,
                                         smartQuickAnswers,
                                         openChatFromUserProfile])
        boolVariables.append(contentsOf: [showInactiveConversations,
                                          showChatSafetyTips,
                                          showChatHeaderWithoutListingForAssistant,
                                          showChatHeaderWithoutUser,
                                          enableCTAMessageType])
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
                           showChatConnectionStatusBar: .makeInt(key: Keys.showChatConnectionStatusBar,
                                                                 defaultValue: 0,
                                                                 groupType: .chat),
                           showChatHeaderWithoutListingForAssistant: .makeBool(key: Keys.showChatHeaderWithoutListingForAssistant,
                                                                               defaultValue: false,
                                                                               groupType: .chat),
                           showChatHeaderWithoutUser: .makeBool(key: Keys.showChatHeaderWithoutUser,
                                                                defaultValue: false,
                                                                groupType: .chat),
                           enableCTAMessageType: .makeBool(key: Keys.enableCTAMessageType,
                                                           defaultValue: false,
                                                           groupType: .chat),
                           expressChatImprovement: .makeInt(key: Keys.expressChatImprovement,
                                                            defaultValue: 0,
                                                            groupType: .chat),
                           smartQuickAnswers: .makeInt(key: Keys.smartQuickAnswers,
                                                       defaultValue: 0,
                                                       groupType: .chat),
                           openChatFromUserProfile: .makeInt(key: Keys.openChatFromUserProfile,
                                                            defaultValue: 0,
                                                            groupType: .chat))
    }
}
