import Foundation
import LGCoreKit
import LGComponents

protocol ChatNavigator {
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?)
    func openListingChat(_ listing: Listing,
                         source: EventParameterTypePage,
                         interlocutor: User?,
                         openChatAutomaticMessage: ChatWrapperMessageType?)
}

final class ChatWireframe: ChatNavigator {

    private let nc: UINavigationController

    private let chatAssembly: ChatAssembly
    private let chatInactiveAssembly: ChatInactiveDetailAssembly

    private let chatRepository: ChatRepository

    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  chatAssembly: LGChatBuilder.standard(nav: nc),
                  chatInactiveAssembly: ChatInactiveDetailBuilder.standard(nc),
                  chatRepository: Core.chatRepository)
    }

    private init(nc: UINavigationController,
                 chatAssembly: ChatAssembly,
                 chatInactiveAssembly: ChatInactiveDetailAssembly,
                 chatRepository: ChatRepository) {
        self.nc = nc
        self.chatAssembly = chatAssembly
        self.chatInactiveAssembly = chatInactiveAssembly
        self.chatRepository = chatRepository
    }

    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?) {
        switch data {
        case let .conversation(conversation):
            openConversation(conversation, source: source, predefinedMessage: predefinedMessage)
        case .inactiveConversations:
            openInactiveConversations()
        case let .inactiveConversation(conversation):
            openInactiveConversation(conversation: conversation)
        case let .listingAPI(listing):
            openListingChat(listing, source: source, interlocutor: nil, openChatAutomaticMessage: nil)
        case let .dataIds(conversationId):
            openChatFromConversationId(conversationId, source: source, predefinedMessage: predefinedMessage)
        }
    }

    func openListingChat(_ listing: Listing,
                         source: EventParameterTypePage,
                         interlocutor: User?,
                         openChatAutomaticMessage: ChatWrapperMessageType?) {
        openChatFrom(listing: listing,
                     source: source,
                     openChatAutomaticMessage: openChatAutomaticMessage,
                     interlocutor: interlocutor)
    }

    func openChatFrom(listing: Listing,
                      source: EventParameterTypePage,
                      openChatAutomaticMessage: ChatWrapperMessageType?,
                      interlocutor: User?) {
        guard let vc = chatAssembly.buildChatFrom(listing: listing,
                                                  source: source,
                                                  openChatAutomaticMessage: openChatAutomaticMessage,
                                                  interlocutor: interlocutor) else { return }
        nc.pushViewController(vc, animated: true)
    }

    func openConversation(_ conversation: ChatConversation,
                          source: EventParameterTypePage,
                          predefinedMessage: String?) {
        let vc = chatAssembly.buildChatFrom(conversation, source: source, predefinedMessage: predefinedMessage)
        nc.pushViewController(vc, animated: true)
    }

    func openInactiveConversations() {
        let vc = chatAssembly.buildChatInactiveConversationsList()
        nc.pushViewController(vc, animated: true)
    }

    func openInactiveConversation(conversation: ChatInactiveConversation) {
        let vc = chatInactiveAssembly.buildChatInactiveConversationDetails(conversation: conversation)
        nc.pushViewController(vc, animated: true)
    }

    func openChatFromConversationId(_ conversationId: String,
                                    source: EventParameterTypePage,
                                    predefinedMessage: String?) {
        nc.showLoadingMessageAlert()

        let completion: ChatConversationCompletion = { [weak self] result in
            self?.nc.dismissLoadingMessageAlert { [weak self] in
                if let conversation = result.value {
                    self?.openConversation(conversation, source: source, predefinedMessage: predefinedMessage)
                } else if let error = result.error {
                    self?.showChatRetrieveError(error)
                }
            }
        }
        chatRepository.showConversation(conversationId, completion: completion)
    }
}

extension ChatWireframe: ChatInactiveConversationsListNavigator { }

private extension ChatWireframe {
    func showChatRetrieveError(_ error: RepositoryError) {
        let message: String
        switch error {
        case .network:
            message = R.Strings.commonErrorConnectionFailed
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = R.Strings.commonChatNotAvailable
        }
        nc.showAutoFadingOutMessageAlert(message: message)
    }
}
