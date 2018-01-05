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

final class QuickChatView: UIView, QuickChatViewType, DirectAnswersSupportType, UIGestureRecognizerDelegate {
    private struct Layout { static let outsideKeyboard: CGFloat = 120.0 }

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
        textViewBottom?.constant = Layout.outsideKeyboard
        backgroundColor = UIColor.clear
    }

    func updateWith(bottomInset: CGFloat, animationTime: TimeInterval,
                    animationOptions: UIViewAnimationOptions, completion: ((Bool) -> Void)? = nil) {
        let color = (bottomInset <= 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.5)
        let alpha: CGFloat = (bottomInset <= 0) ? 0 : 1
        textViewBottom?.constant = (bottomInset <= 0) ? Layout.outsideKeyboard : -(bottomInset + Metrics.margin)

        UIView.animate(withDuration: animationTime,
                       delay: 0,
                       options: animationOptions,
                       animations: {
                        self.textView.alpha = alpha
                        self.directAnswersView.alpha = alpha
                        self.tableView.alpha = alpha
                        self.backgroundColor = color
                        self.layoutIfNeeded()
        }, completion: completion)
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

    func addDismissGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = true
        addGestureRecognizer(gesture)
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else { return false }
        let indexPath = tableView.indexPathForRow(at: touch.location(in: tableView))
        if touchView.isDescendant(of: tableView), let index = indexPath, let _ = tableView.cellForRow(at: index) {
            return false
        }
        return !touchView.isDescendant(of: directAnswersView) && !touchView.isDescendant(of: textView)
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
        tableView.keyboardDismissMode = .onDrag

        tableView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(tableView)
        tableView.layout(with: self).topMargin().fillHorizontal()
        tableView.layout(with: directAnswersView).above(by: -Metrics.shortMargin)
        tableView.backgroundColor = .clear
        setupDirectMessages()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quickChatViewModel.directChatMessages.value.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        quickChatViewModel.directMessagesItemPressed()
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

    // MARK: DirectAnswersHorizontalViewDelegate

    func setupDirectMessages() {
        tableView.isCellHiddenBlock = { return $0.contentView.isHidden }
        tableView.didSelectRowAtIndexPath = {  [weak self] _ in self?.quickChatViewModel.directMessagesItemPressed() }

        tableView.dataSource = self
        tableView.delegate = self
        ChatCellDrawerFactory.registerCells(tableView)

        tableView.transform = CGAffineTransform.invertedVertically
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = DirectAnswersHorizontalView.Layout.Height.estimatedRow
        tableView.separatorStyle = .none
    }

}
