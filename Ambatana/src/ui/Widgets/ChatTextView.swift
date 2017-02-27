//
//  ChatTextField.swift
//  LetGo
//
//  Created by Eli Kohen on 02/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


extension Reactive where Base: ChatTextView {
    var text: ControlProperty<String?> {
        return self.base.textView.rx.text
    }

    var placeholder: UIBindingObserver<Base, String?> {
        return UIBindingObserver<Base, String?>(UIElement: self.base) { (textView, placeholder) -> () in
            textView.placeholder = placeholder
        }
    }

    var send: Observable<String> {
        let chatTextView = self.base
        return chatTextView.tapEvents.map { [weak chatTextView] in chatTextView?.textView.text ?? "" }
    }

    var focus: Observable<Bool> {
        return self.base.focus.asObservable().skip(1)
    }
}


class ChatTextView: UIView {

    static let minimumHeight: CGFloat = 50
    static let minimumWidth: CGFloat = 100
    static let minimumButtonWidth: CGFloat = 70
    static let buttonMargin: CGFloat = 3
    
    var currentDefaultText = ""

    var placeholder: String? {
        get {
            return textView.placeholder
        }
        set {
            textView.placeholder = newValue
        }
    }

    var hasFocus: Bool {
        return focus.value
    }
    
    var isInitialText: Bool {
        return textView.text == currentDefaultText
    }
    
    
    fileprivate let textView = UITextField()
    fileprivate let sendButton = UIButton(type: .custom)
    fileprivate let focus = Variable<Bool>(false)
    fileprivate var initialTextActive = false

    private static let elementsMargin: CGFloat = 10
    private static let textViewMaxHeight: CGFloat = 120

    fileprivate let tapEvents = PublishSubject<Void>()

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder() || super.becomeFirstResponder()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder() || super.resignFirstResponder()
    }

    override var isFirstResponder : Bool {
        return textView.isFirstResponder || super.isFirstResponder
    }


    // MARK: - Public methods

    func clear() {
        textView.text = ""
        sendButton.isEnabled = false
    }
    
    func setInitialText(_ defaultText: String) {
        textView.text = defaultText
        currentDefaultText = defaultText
        sendButton.isEnabled = true
        initialTextActive = true
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
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: ChatTextView.minimumHeight))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: ChatTextView.minimumWidth))

        setupBackgroundsWCorners()

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        addSubview(textView)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        addSubview(sendButton)

        var views = [String: Any]()
        views["textView"] = textView
        views["sendButton"] = sendButton

        var metrics = [String: Any]()
        metrics["margin"] = ChatTextView.elementsMargin
        metrics["maxHeight"] = ChatTextView.textViewMaxHeight
        metrics["minButtonWidth"] = ChatTextView.minimumButtonWidth
        metrics["buttonMargin"] = ChatTextView.buttonMargin

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[textView]-margin-[sendButton(>=minButtonWidth)]-buttonMargin-|",
            options: [.alignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[textView(<=maxHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
        sendButton.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: ChatTextView.minimumHeight-(ChatTextView.buttonMargin*2)))
    }

    private func setupUI() {
        textView.tintColor = UIColor.primaryColor
        textView.backgroundColor = UIColor.clear
        textView.returnKeyType = .send
        textView.delegate = self
        sendButton.setStyle(.primary(fontSize: .medium))
        sendButton.setTitle(LGLocalizedString.chatSendButton, for: .normal)
    }

    private func setupRX() {
        textView.rx.text.map { !($0 ?? "").trim.isEmpty }.bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
        sendButton.rx.tap.bindTo(tapEvents).addDisposableTo(disposeBag)
    }

    private func setupBackgroundsWCorners() {
        let leftBackground = UIView()
        leftBackground.translatesAutoresizingMaskIntoConstraints = false
        leftBackground.backgroundColor = UIColor.white
        leftBackground.clipsToBounds = true
        leftBackground.layer.cornerRadius = LGUIKitConstants.chatTextViewCornerRadius
        addSubview(leftBackground)
        let rightBackground = UIView()
        rightBackground.translatesAutoresizingMaskIntoConstraints = false
        rightBackground.backgroundColor = UIColor.white
        rightBackground.clipsToBounds = true
        rightBackground.layer.cornerRadius = ChatTextView.minimumHeight/2
        addSubview(rightBackground)
        var views = [String: Any]()
        views["leftBckg"] = leftBackground
        views["rightBckg"] = rightBackground
        var metrics = [String: Any]()
        metrics["margin"] = ChatTextView.minimumWidth/2

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[leftBckg]-margin-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[rightBckg]-0-|",
            options: [], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[leftBckg]-0-|",
            options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[rightBckg]-0-|",
            options: [], metrics: nil, views: views))

    }
}


extension ChatTextView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        focus.value = true
        if initialTextActive {
            clear()
        }
        initialTextActive = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        focus.value = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.trim.isEmpty else { return false }
        tapEvents.onNext(Void())
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.hasEmojis() else { return false }
        return true
    }
}


// MARK: - AccesibilityIds

fileprivate extension ChatTextView {
    func setAccesibilityIds() {
        textView.accessibilityId = .chatTextViewTextField
        sendButton.accessibilityId = .chatTextViewSendButton
    }
}
