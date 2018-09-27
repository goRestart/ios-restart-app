import LGCoreKit
import LGComponents

struct ConversationCellData: Equatable {
    let status: ConversationCellStatus
    let conversationId: String?
    let userId: String?
    let userName: String
    let userImageUrl: URL?
    let userImagePlaceholder: UIImage?
    let userType: UserType?
    let amISelling: Bool
    let listingId: String?
    let listingName: String
    let listingImageUrl: URL?
    let unreadCount: Int
    let messageDate: Date?
    let isTyping: Bool
    let isFakeListing: Bool
    
    static func make(from conversation: ChatConversation) -> ConversationCellData {
        let isFakeListing = (conversation.listing?.isFakeListing ?? false) && !(conversation.interlocutor?.userType.isDummy ?? true)
        return ConversationCellData(status: conversation.conversationCellStatus,
                                    conversationId: conversation.objectId,
                                    userId: conversation.interlocutor?.objectId,
                                    userName: conversation.interlocutor?.name ?? "",
                                    userImageUrl: conversation.interlocutor?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(conversation.interlocutor?.objectId,
                                                                                   name: conversation.interlocutor?.name),
                                    userType: conversation.interlocutor?.userType,
                                    amISelling: conversation.amISelling,
                                    listingId: conversation.listing?.objectId,
                                    listingName: conversation.listing?.name ?? "",
                                    listingImageUrl: conversation.listing?.image?.fileURL,
                                    unreadCount: conversation.unreadMessageCount,
                                    messageDate: conversation.lastMessageSentAt,
                                    isTyping: conversation.interlocutorIsTyping.value,
                                    isFakeListing: isFakeListing)
    }
}
