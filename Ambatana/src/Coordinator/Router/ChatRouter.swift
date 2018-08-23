import Foundation
import LGCoreKit
import LGComponents

protocol ChatNavigator {
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?)
}

final class ChatRouter: ChatNavigator {
    private weak var navigationController: UINavigationController?
    private let chatAssembly: ChatAssembly
    private let chatRepository: ChatRepository

    convenience init(navigationController: UINavigationController) {
        self.init(navigationController: navigationController,
                  chatAssembly: LGChatBuilder.standard(nav: navigationController),
                  chatRepository: Core.chatRepository)
    }

    private init(navigationController: UINavigationController,
                 chatAssembly: ChatAssembly,
                 chatRepository: ChatRepository) {
        self.navigationController = navigationController
        self.chatAssembly = chatAssembly
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
        navigationController?.pushViewController(vc, animated: true)
    }

    func openConversation(_ conversation: ChatConversation,
                          source: EventParameterTypePage,
                          predefinedMessage: String?) {
        let vc = chatAssembly.buildChatFrom(conversation, source: source, predefinedMessage: predefinedMessage)
        navigationController?.pushViewController(vc, animated: true)
    }

    func openInactiveConversations() {
        let vc = chatAssembly.buildChatInactiveConversationsList()
        navigationController?.pushViewController(vc, animated: true)
    }

    func openInactiveConversation(conversation: ChatInactiveConversation) {
        let vc = chatAssembly.buildChatInactiveConversationDetails(conversation: conversation)
        navigationController?.pushViewController(vc, animated: true)
    }

    func openChatFromConversationId(_ conversationId: String,
                                    source: EventParameterTypePage,
                                    predefinedMessage: String?) {
        navigationController?.showLoadingMessageAlert()

        let completion: ChatConversationCompletion = { [weak self] result in
            self?.navigationController?.dismissLoadingMessageAlert { [weak self] in
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

extension ChatRouter: ChatInactiveConversationsListNavigator { }

private extension ChatRouter {
    func showChatRetrieveError(_ error: RepositoryError) {
        let message: String
        switch error {
        case .network:
            message = R.Strings.commonErrorConnectionFailed
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
             .wsChatError, .searchAlertError:
            message = R.Strings.commonChatNotAvailable
        }
        navigationController?.showAutoFadingOutMessageAlert(message: message)
    }
}
