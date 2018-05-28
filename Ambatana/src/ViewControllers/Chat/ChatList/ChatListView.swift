import Foundation
import LGCoreKit
import RxSwift
import LGComponents

protocol ChatListViewDelegate: class {
    func chatListView(_ chatListView: ChatListView, showDeleteConfirmationWithTitle title: String, message: String,
                      cancelText: String, actionText: String, action: @escaping () -> ())
    func chatListViewDidStartArchiving(_ chatListView: ChatListView)
    func chatListView(_ chatListView: ChatListView, didFinishArchivingWithMessage message: String?)
    func chatListView(_ chatListView: ChatListView, didFinishUnarchivingWithMessage message: String?)
}

class ChatListView: ChatGroupedListView, ChatListViewModelDelegate {

    // Constants
    private static let tabBarBottomInset: CGFloat = 44

    // Data
    var viewModel: ChatListViewModel
    weak var delegate: ChatListViewDelegate?
    
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init<T: ChatListViewModel>(viewModel: T) {
        self.init(viewModel: viewModel, sessionManager: Core.sessionManager, frame: CGRect.zero)
    }

    override init<T: ChatListViewModel>(viewModel: T, sessionManager: SessionManager, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, frame: frame)

        viewModel.delegate = self
    }

    override init?<T: ChatListViewModel>(viewModel: T, sessionManager: SessionManager, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, sessionManager: sessionManager, coder: aDecoder)

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupUI() {
        super.setupUI()

        let cellNib = UINib(nibName: "ConversationCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: ConversationCell.reusableID)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.rowHeight = ConversationCell.defaultHeight

        footerButton.setTitle(viewModel.titleForDeleteButton, for: .normal)
        footerButton.addTarget(self, action: #selector(ChatListView.deleteButtonPressed), for: .touchUpInside)
    }

    override func setupRx() {
        super.setupRx()
        
        viewModel.shouldScrollToTop.subscribeNext { [weak self] shouldScrollToTop in
            guard let tableView = self?.tableView, tableView.numberOfRows(inSection: 0) > 0 else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }.disposed(by: disposeBag)
    }
    

    // MARK: - ChatListViewModelDelegate Methods

    func chatListViewModelDidFailArchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf,
                didFinishArchivingWithMessage: R.Strings.chatListArchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedArchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishArchivingWithMessage: nil)
        }
    }

    func chatListViewModelDidFailUnarchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishUnarchivingWithMessage: R.Strings.chatListUnarchiveErrorMultiple)
        }
    }

    func chatListViewModelDidSucceedUnarchivingChats(_ viewModel: ChatListViewModel) {
        viewModel.refresh { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.chatListView(strongSelf, didFinishUnarchivingWithMessage: nil)
        }
    }
    
    func chatListViewModel(_: ChatListViewModel, showDeleteConfirmationWithTitle title: String,
                           message: String, cancelText: String, actionText: String, action: @escaping () -> ()) {
        delegate?.chatListView(
            self,
            showDeleteConfirmationWithTitle: title,
            message: message,
            cancelText: cancelText,
            actionText: actionText) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.chatListViewDidStartArchiving(strongSelf)
                action()
        }
    }

    
    // MARK: - UITableViewDataSource

    override func cellForRowAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = super.cellForRowAtIndexPath(indexPath)

        guard let chatData = viewModel.conversationDataAtIndex(indexPath.row) else { return cell }
        guard let chatCell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reusableID,
            for: indexPath) as? ConversationCell else { return cell }

        chatCell.tag = (indexPath as NSIndexPath).hash // used for cell reuse on "setupCellWithData"
        chatCell.setupCellWithData(chatData, indexPath: indexPath)
        
        let isSelected = viewModel.isConversationSelected(index: indexPath.row)
        if isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        return chatCell
    }


    // MARK: - UITableViewDelegate

    override func didSelectRowAtIndex(_ index: Int, editing: Bool) {
        super.didSelectRowAtIndex(index, editing: editing)
        viewModel.selectConversation(index: index, editing: editing)
    }
    
    override func didDeselectRowAtIndex(_ index: Int, editing: Bool) {
        super.didDeselectRowAtIndex(index, editing: editing)
        viewModel.deselectConversation(index: index, editing: editing)
    }
    
    override func setEditing(_ editing: Bool) {
        super.setEditing(editing)
        guard !editing else { return }
        viewModel.deselectAllConversations()
    }


    // MARK: - Private Methods

    @objc func deleteButtonPressed() {
        viewModel.deleteButtonPressed()
    }
}
