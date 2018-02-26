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
    private struct Duration {
        static let flashInTable: TimeInterval = TimeInterval(1)
        static let flashOutTable: TimeInterval = TimeInterval(3)
    }
    
    var isRemovedWhenResigningFirstResponder = true
    var isTableInteractionEnabled = true

    var rxChatTextView: Reactive<ChatTextView> { return textView.rx }
    var rxToSendMessage: Observable<String> { return textView.rx.send }

    let quickChatViewModel: QuickChatViewModel

    private let textView = ChatTextView()
    private var textViewBottom: NSLayoutConstraint?

    var directAnswersViewTopAnchor: NSLayoutYAxisAnchor { return directAnswersView.topAnchor }
    private let directAnswersView = DirectAnswersHorizontalView(answers: [])
    private let tableView = CustomTouchesTableView()
    private let binder = QuickChatViewBinder()

    private var alphaAnimationHideTimer: Timer?

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
        textViewBottom?.constant = isRemovedWhenResigningFirstResponder ? 4*Metrics.margin : -Metrics.margin
        backgroundColor = UIColor.clear
    }

    func updateWith(bottomInset: CGFloat, animationTime: TimeInterval,
                    animationOptions: UIViewAnimationOptions, completion: ((Bool) -> Void)? = nil) {
        let color = (bottomInset <= 0) ? UIColor.clear : UIColor.black.withAlphaComponent(0.5)
        let animationFunc = (bottomInset <= 0) ? dissappearAnimation : revealAnimation

        if bottomInset <= 0 {
            textViewBottom?.constant = isRemovedWhenResigningFirstResponder ? Layout.outsideKeyboard : -Metrics.margin
        } else {
            textViewBottom?.constant = -(bottomInset + Metrics.margin)
        }
        UIView.animate(withDuration: animationTime,
                       delay: 0,
                       options: animationOptions,
                       animations: {
                        animationFunc()
                        self.backgroundColor = color
                        self.layoutIfNeeded()
        }, completion: completion)
    }

    func revealAnimation() {
        self.textView.alpha = 1
        self.directAnswersView.alpha = 1
        self.tableView.alpha = 1
    }

    func dissappearAnimation() {
        alphaAnimationHideTimer?.invalidate()
        if isRemovedWhenResigningFirstResponder {
            textView.alpha = 0
            directAnswersView.alpha = 0
            tableView.alpha = 0
        }
    }

    func setInitialText(_ text: String) {
        textView.setText(text)
        textView.resignFirstResponder()
    }

    func clearChatTextView() {
        textView.clear()
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

    func showDirectMessages() {
        guard !textView.isFirstResponder else { return }
        fireHideAnimationTimer()
    }

    private func fireHideAnimationTimer() {
        if alphaAnimationHideTimer == nil {
            UIView.animate(withDuration: Duration.flashInTable,
                           animations: { [weak self] in
                            self?.tableView.alpha = 1
            }) { (completion) in
                self.alphaAnimationHideTimer?.fire()
            }
        }
        alphaAnimationHideTimer?.invalidate()
        alphaAnimationHideTimer = Timer.scheduledTimer(timeInterval: TimeInterval(3),
                                                       target: self,
                                                       selector: #selector(dismissTimer),
                                                       userInfo: nil, repeats: false)
    }

    @objc private func dismissTimer() {
        guard alphaAnimationHideTimer != nil else { return }
        UIView.animate(withDuration: Duration.flashOutTable,
                       animations: { [weak self] in
                        self?.tableView.alpha = 0
        })
        alphaAnimationHideTimer = nil
    }

    func addDismissGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = true
        addGestureRecognizer(gesture)
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard !gestureRecognizer.isKind(of: UISwipeGestureRecognizer.self) else { return true }
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
        tableView.didSelectRowAtIndexPath = {  [weak self] _ in
            self?.quickChatViewModel.directMessagesItemPressed()
            self?.textView.resignFirstResponder()
        }

        tableView.dataSource = self
        tableView.delegate = self
        ChatCellDrawerFactory.registerCells(tableView)

        tableView.transform = CGAffineTransform.invertedVertically
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = DirectAnswersHorizontalView.Layout.Height.estimatedRow
        tableView.separatorStyle = .none
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let firstResponder = textView.isFirstResponder

        let insideTable = tableView.point(inside: convert(point, to: tableView),  with: event)
            && alphaAnimationHideTimer != nil
            && isTableInteractionEnabled

        let insideTextView = textView.point(inside: convert(point, to: textView), with: event)
        let insideDirectAnswers = directAnswersView.point(inside: convert(point, to: directAnswersView), with: event)

        return firstResponder || insideTable || insideTextView || insideDirectAnswers
    }
}
