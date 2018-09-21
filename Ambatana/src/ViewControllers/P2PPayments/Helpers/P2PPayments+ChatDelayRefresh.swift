import Foundation

enum P2PPayments {
    private static let chatDelay: TimeInterval = 2

    static func performAfterChatDelay(_ function: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + P2PPayments.chatDelay) {
            function()
        }
    }
}
