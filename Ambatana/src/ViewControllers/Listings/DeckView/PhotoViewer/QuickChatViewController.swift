import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class QuickChatViewController: BaseViewController {
    fileprivate let viewModel = QuickChatViewModel()
    fileprivate let chatView = QuickChatView()

    var isTableInteractionEnabled: Bool = false {
        didSet { chatView.isTableInteractionEnabled = isTableInteractionEnabled }
    }

    private let featureFlags: FeatureFlaggeable
    private let disposeBag = DisposeBag()

    convenience init(listingViewModel: ListingViewModel) {
        self.init(listingViewModel: listingViewModel, featureFlags: FeatureFlags.sharedInstance)
    }

    private init(listingViewModel: ListingViewModel, featureFlags: FeatureFlaggeable) {
        self.featureFlags = featureFlags

        super.init(viewModel: viewModel,
                   nibName: nil,
                   statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .light),
                   swipeBackGestureEnabled: true)
        self.viewModel.listingViewModel = listingViewModel

        self.edgesForExtendedLayout = .all
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        self.view = chatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChat()
        setupRx()
    }

    private func setupChat() {
        chatView.tableView.dataSource = self
        chatView.tableView.delegate = self
        chatView.tableView.didSelectRowAtIndexPath = {  [weak self] _ in
            self?.viewModel.directMessagesItemPressed()
        }

        chatView.directAnswersView.delegate = viewModel
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.directMessages.asDriver(onErrorJustReturn: .composite([])).drive(rx.directMessages),
            viewModel.rx.chatState
                .asDriver(onErrorJustReturn: QuickChatViewState(quickAnswersState: nil,
                                                                proState: nil,
                                                                isInterested: false))
                .drive(rx.chatState)
        ]
        bindings.forEach { $0.disposed(by: disposeBag) }
    }
}

// MARK: DirectAnswersSupportType
extension QuickChatViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.directChatMessages.value.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.directMessagesItemPressed()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = viewModel.directChatMessages.value
        guard let message = messages[safeAt: indexPath.row] else { return UITableViewCell() }
        let drawer = ChatCellDrawerFactory.drawerForMessage(message,
                                                            autoHide: true,
                                                            disclosure: true,
                                                            meetingsEnabled: featureFlags.chatNorris.isActive)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message, bubbleColor: nil)
        cell.transform = tableView.transform

        return cell
    }

    fileprivate func handleChatChange(_ change: CollectionChange<ChatViewMessage>) {
        switch change {
        case .insert(_, let message):
            // if the message is already in the table we don't perform animations
            if let objectID = message.objectId, viewModel.messageExists(objectID) {
                chatView.tableView.handleCollectionChange(change, animation: .none)
            } else {
                chatView.tableView.handleCollectionChange(change, animation:.top)
            }
        default:
            chatView.tableView.handleCollectionChange(change, animation: .none)
        }
    }
}

private extension QuickChatViewState {
    var areQuickAnswersEnabled: Bool { return quickAnswersState != nil }
    var quickAnswers: [QuickAnswer] { return  quickAnswersState?.quickAnswers ?? [] }

    var isPro: Bool { return proState != nil }
    var proText: String { return proState?.message ?? "" }
    var proImage: UIImage? { return proState?.icon }
}

extension Reactive where Base: QuickChatViewController {
    var chatState: Binder<QuickChatViewState> {
        return Binder(self.base) { controller, chatState in
            // the order is important
            controller.chatView.setChatEnabled(chatState.areQuickAnswersEnabled)
            controller.chatView.updateDirectChatWith(answers: chatState.quickAnswers)
            controller.chatView.setSellerAsPro(chatState.isPro)
            controller.chatView.setPro(chatState.proText, image: chatState.proImage)
            controller.chatView.setListingAs(interested: chatState.isInterested)
        }
    }

    var directMessages: Binder<CollectionChange<ChatViewMessage>> {
        return Binder(self.base) { controller, change in
            if change.element() != nil {
                controller.chatView.showDirectMessages()
            }
            controller.handleChatChange(change)
        }
    }
}
