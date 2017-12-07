//
//  QuickChatView.swift
//  LetGo
//
//  Created by Facundo Menzella on 30/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class QuickChatView: UIView {
    private struct Layout { static let outsideKeyboard: CGFloat = 60 }
    let quickChatViewModel: QuickChatViewModel

    private let textView = ChatTextView()
    private var textViewBottom: NSLayoutConstraint?

    private let directAnswersView = DirectAnswersHorizontalView(answers: [])
    private let tableView = CustomTouchesTableView()

    init(chatViewModel: QuickChatViewModel) {
        self.quickChatViewModel = chatViewModel
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        textViewBottom?.constant = Layout.outsideKeyboard
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    func updateWith(keyboardChange: KeyboardChange) {
        layoutIfNeeded()
        let height = bounds.height - keyboardChange.origin
        textViewBottom?.constant = -height - Metrics.margin
        UIView.animate(withDuration: TimeInterval(keyboardChange.animationTime),
                       delay: 0,
                       options: keyboardChange.animationOptions,
                       animations: { 
                        self.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: UI


    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
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
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        tableView.layout(with: self).topMargin().fillHorizontal()
        tableView.layout(with: directAnswersView).above(by: -Metrics.shortMargin)
        tableView.alpha = 0
        tableView.backgroundColor = .clear
    }
}
