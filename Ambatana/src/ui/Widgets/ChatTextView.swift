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

    var didBeginEditing: ControlEvent<()> { return self.base.textView.rx.controlEvent([.editingDidBegin]) }
    
    var didEndEditing: ControlEvent<()> { return self.base.textView.rx.controlEvent([.editingDidEnd]) }

    var placeholder: Binder<String?> {
        return Binder<String?>(self.base) { (textView, placeholder) in
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


final class ChatTextView: UIView {
    static let minimumHeight: CGFloat = 44
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
    

    fileprivate let background = UIView()
    fileprivate let textView = UITextField()
    fileprivate let sendButton = LetgoButton(withStyle: .primary(fontSize: .medium))
    fileprivate let focus = Variable<Bool>(false)
    fileprivate var initialTextActive = false

    private static let elementsMargin: CGFloat = 10
    private static let textViewMaxHeight: CGFloat = 120

    fileprivate let tapEvents = PublishSubject<Void>()

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle
    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric,
                                                              height: ChatTextView.minimumHeight) }
    
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
        setupBackgroundsWCorners()

        addSubviewsForAutoLayout([textView, sendButton])
        textView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        sendButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: ChatTextView.textViewMaxHeight),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: ChatTextView.elementsMargin),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ChatTextView.elementsMargin),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.margin),
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: ChatTextView.elementsMargin),
            sendButton.widthAnchor.constraint(greaterThanOrEqualToConstant: ChatTextView.minimumButtonWidth),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ChatTextView.buttonMargin),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: ChatTextView.minimumHeight-(ChatTextView.buttonMargin*2))
        ])
    }

    private func setupUI() {
        textView.tintColor = UIColor.primaryColor
        textView.backgroundColor = .clear
        textView.returnKeyType = .send
        textView.delegate = self
        sendButton.setTitle(LGLocalizedString.chatSendButton, for: .normal)
    }

    private func setupRX() {
        textView.rx.text.map { !($0 ?? "").trim.isEmpty }.bind(to: sendButton.rx.isEnabled).disposed(by: disposeBag)
        sendButton.rx.tap.bind(to: tapEvents).disposed(by: disposeBag)
    }

    private func setupBackgroundsWCorners() {
        addSubviewForAutoLayout(background)
        background.backgroundColor = UIColor.white
        background.layout(with: self).fill()
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
        guard !string.containsEmoji else { return false }
        return true
    }

    func setTextViewBackgroundColor(_ color: UIColor) {
        background.backgroundColor = color
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        background.setRoundedCorners()
        sendButton.setRoundedCorners()
    }
}


// MARK: - AccesibilityIds

fileprivate extension ChatTextView {
    func setAccesibilityIds() {
        textView.set(accessibilityId: .chatTextViewTextField)
        sendButton.set(accessibilityId: .chatTextViewSendButton)
    }
}
