public protocol ChatCallToActionData {
    var key: String? { get }
    var title: String? { get }
    var text: String? { get }
    var image: ChatCallToActionImage? { get }
}

struct LGChatCallToActionData: ChatCallToActionData, Equatable {

    let key: String?
    let title: String?
    let text: String?
    let image: ChatCallToActionImage?

    // MARK: Equatable

    static func ==(lhs: LGChatCallToActionData, rhs: LGChatCallToActionData) -> Bool {
        guard let lhsImage = lhs.image as? LGChatCallToActionImage, let rhsImage = rhs.image as? LGChatCallToActionImage else { return false }
        return lhs.key == rhs.key &&
            lhs.text == rhs.text &&
            lhs.text == rhs.text &&
            lhsImage == rhsImage
    }
}
