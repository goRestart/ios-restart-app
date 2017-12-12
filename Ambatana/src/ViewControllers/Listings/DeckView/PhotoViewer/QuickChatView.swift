//
//  QuickChatView.swift
//  LetGo
//
//  Created by Facundo Menzella on 30/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import LGCoreKit

typealias DirectAnswersSupportType = UITableViewDataSource & UITableViewDelegate

final class QuickChatView: UIView, QuickChatViewType, DirectAnswersSupportType {
    private struct Layout { static let outsideKeyboard: CGFloat = 60 }

    var rx_chatTextView: Reactive<ChatTextView> { return textView.rx }
    let quickChatViewModel: QuickChatViewModel

    private let textView = ChatTextView()
    private var textViewBottom: NSLayoutConstraint?

    private let directAnswersView = DirectAnswersHorizontalView(answers: [])
    private let tableView = CustomTouchesTableView()
    private let binder = QuickChatViewBinder()

    init(chatViewModel: QuickChatViewModel) {
        self.quickChatViewModel = chatViewModel
        super.init(frame: .zero)
        setupUI()

        binder.quickChatView = self
        binder.bind(to: quickChatViewModel)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        textViewBottom?.constant = 4*Metrics.margin
        backgroundColor = UIColor.clear
    }

    func updateWith(bottomInset: CGFloat, animationTime: TimeInterval, animationOptions: UIViewAnimationOptions) {
        textViewBottom?.constant = -bottomInset - Metrics.margin
        let color = (bottomInset == 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.5)
        UIView.animate(withDuration: animationTime,
                       delay: 0,
                       options: animationOptions,
                       animations: {
                        self.backgroundColor = color
                        self.superview?.layoutIfNeeded()
        }, completion: nil)
    }

    func setInitialText(_ text: String) {
        textView.setText(text)
        textView.resignFirstResponder()
    }

    func updateDirectChatWith(answers: [[QuickAnswer]], isDynamic: Bool) {
        directAnswersView.update(answers: answers, isDynamic: isDynamic)
    }

    func handleChatChange(_ change: CollectionChange<ChatViewMessage>) {
        switch change {
        case .insert(_, let message):
            // if the message is already in the table we don't perform animations
            if let objectID = message.objectId, quickChatViewModel.messageExists(objectID) {
                tableView.handleCollectionChange(change, animation: .none)
            } else {
                tableView.handleCollectionChange(change, animation:.top)
            }
        default:
            tableView.handleCollectionChange(change, animation: .none)
        }
    }

    // MARK: UI


    private func setupUI() {
        backgroundColor = .clear

        setupTextView()
        setupDirectAnswers()
        setupTableView()
    }

    private func setupTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        textView.layout(with: self).fillHorizontal(by: Metrics.margin)
        textViewBottom = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Layout.outsideKeyboard)
        textViewBottom?.isActive = true

        textView.backgroundColor = .clear
    }

    private func setupDirectAnswers() {
        directAnswersView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(directAnswersView)
        directAnswersView.layout(with: self).fillHorizontal()
        directAnswersView.layout(with: textView).above(by: -Metrics.shortMargin)

        directAnswersView.backgroundColor = .clear
        directAnswersView.style = .light
        directAnswersView.delegate = quickChatViewModel
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        tableView.layout(with: self).topMargin().fillHorizontal()
        tableView.layout(with: directAnswersView).above(by: -Metrics.shortMargin)
        tableView.backgroundColor = .clear

        setupDirectMessages()
    }

    // MARK: DirectAnswersHorizontalViewDelegate

    func setupDirectMessages() {
        tableView.dataSource = self
        tableView.delegate = self
        ChatCellDrawerFactory.registerCells(tableView)

        // TODO: Check what is this shit
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = DirectAnswersHorizontalView.Layout.Height.estimatedRow
        tableView.separatorStyle = .none

        tableView.isCellHiddenBlock = { return $0.contentView.isHidden }
        tableView.didSelectRowAtIndexPath = {  [weak self] _ in
            self?.quickChatViewModel.directMessagesItemPressed()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickChatViewModel.directChatMessages.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messages = quickChatViewModel.directChatMessages.value
        guard 0..<messages.count ~= indexPath.row else { return UITableViewCell() }
        let message = messages[indexPath.row]
        let drawer = ChatCellDrawerFactory.drawerForMessage(message, autoHide: true, disclosure: true)
        let cell = drawer.cell(tableView, atIndexPath: indexPath)

        drawer.draw(cell, message: message)
        cell.transform = tableView.transform

        return cell
    }

}
