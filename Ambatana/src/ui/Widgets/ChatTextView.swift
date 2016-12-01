//
//  ChatTextField.swift
//  LetGo
//
//  Created by Eli Kohen on 02/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class ChatTextView: UIView {

    static let minimumHeight: CGFloat = 50
    static let minimumWidth: CGFloat = 100
    static let minimumButtonWidth: CGFloat = 70
    static let buttonMargin: CGFloat = 3

    var placeholder: String? {
        get {
            return textView.placeholder
        }
        set {
            textView.placeholder = newValue
        }
    }

    var rx_text: Observable<String> {
        return textView.rx_text.asObservable()
    }

    var rx_send: Observable<String> {
        return tapEvents.map { [weak self] in self?.textView.text ?? "" }
    }

    var rx_focus: Observable<Bool> {
        return focus.asObservable().skip(1)
    }

    var hasFocus: Bool {
        return focus.value
    }

    private let textView = UITextField()
    private let sendButton = UIButton(type: .Custom)
    private let focus = Variable<Bool>(false)

    private static let elementsMargin: CGFloat = 10
    private static let textViewMaxHeight: CGFloat = 120

    private let tapEvents = PublishSubject<Void>()

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder() || super.resignFirstResponder()
    }

    override func isFirstResponder() -> Bool {
        return textView.isFirstResponder() || super.isFirstResponder()
    }


    // MARK: - Public methods

    func clear() {
        textView.text = ""
        sendButton.enabled = false
    }
    
    func setupInitText() {
        textView.text = LGLocalizedString.chatExpressTextFieldText
        sendButton.enabled = true
    }


    // MARK: - Private methods

    private func setup() {
        setupConstraints()
        setupUI()
        setupRX()
    }

    private func setupConstraints() {
        if height < ChatTextView.minimumHeight {
            height = ChatTextView.minimumHeight
        }
        if width < ChatTextView.minimumWidth {
            width = ChatTextView.minimumWidth
        }
        addConstraint(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: ChatTextView.minimumHeight))
        addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: ChatTextView.minimumWidth))

        setupBackgroundsWCorners()

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        addSubview(textView)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        addSubview(sendButton)

        var views = [String: AnyObject]()
        views["textView"] = textView
        views["sendButton"] = sendButton

        var metrics = [String: AnyObject]()
        metrics["margin"] = ChatTextView.elementsMargin
        metrics["maxHeight"] = ChatTextView.textViewMaxHeight
        metrics["minButtonWidth"] = ChatTextView.minimumButtonWidth
        metrics["buttonMargin"] = ChatTextView.buttonMargin

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[textView]-margin-[sendButton(>=minButtonWidth)]-buttonMargin-|",
            options: [.AlignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[textView(<=maxHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
        sendButton.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: ChatTextView.minimumHeight-(ChatTextView.buttonMargin*2)))
    }

    private func setupUI() {
        textView.tintColor = UIColor.primaryColor
        textView.backgroundColor = UIColor.clearColor()
        textView.returnKeyType = .Send
        textView.delegate = self
        sendButton.setStyle(.Primary(fontSize: .Medium))
        sendButton.setTitle(LGLocalizedString.chatSendButton, forState: .Normal)
    }

    private func setupRX() {
        textView.rx_text.map { !$0.trim.isEmpty }.bindTo(sendButton.rx_enabled).addDisposableTo(disposeBag)
        sendButton.rx_tap.bindTo(tapEvents).addDisposableTo(disposeBag)
    }

    private func setupBackgroundsWCorners() {
        let leftBackground = UIView()
        leftBackground.translatesAutoresizingMaskIntoConstraints = false
        leftBackground.backgroundColor = UIColor.whiteColor()
        leftBackground.clipsToBounds = true
        leftBackground.layer.cornerRadius = LGUIKitConstants.chatTextViewCornerRadius
        addSubview(leftBackground)
        let rightBackground = UIView()
        rightBackground.translatesAutoresizingMaskIntoConstraints = false
        rightBackground.backgroundColor = UIColor.whiteColor()
        rightBackground.clipsToBounds = true
        rightBackground.layer.cornerRadius = ChatTextView.minimumHeight/2
        addSubview(rightBackground)
        var views = [String: AnyObject]()
        views["leftBckg"] = leftBackground
        views["rightBckg"] = rightBackground
        var metrics = [String: AnyObject]()
        metrics["margin"] = ChatTextView.minimumWidth/2

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[leftBckg]-margin-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[rightBckg]-0-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[leftBckg]-0-|",
            options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[rightBckg]-0-|",
            options: [], metrics: nil, views: views))

    }
}


extension ChatTextView: UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        focus.value = true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        focus.value = false
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let text = textField.text where !text.trim.isEmpty else { return false }
        tapEvents.onNext(Void())
        return true
    }
}


// MARK: - AccesibilityIds

private extension ChatTextView {
    func setAccesibilityIds() {
        textView.accessibilityId = .ChatTextViewTextField
        sendButton.accessibilityId = .ChatTextViewSendButton
    }
}
