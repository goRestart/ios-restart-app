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

    var rx_text: Observable<String> {
        return textView.rx_text.asObservable()
    }

    var rx_send: Observable<String> {
        return sendButton.rx_tap.map { [weak self] in self?.textView.text ?? "" }
    }

    private let textView = UITextView()
    private let sendButton = UIButton(type: .Custom)

    private static let elementsMargin: CGFloat = 10
    private static let textViewMaxHeight: CGFloat = 120

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupUI()
        setupRX()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public methods

    func clear() {
        textView.text = ""
    }


    // MARK: - Private methods

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

        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)

        var views = [String: AnyObject]()
        views["textView"] = textView
        views["sendButton"] = sendButton

        var metrics = [String: AnyObject]()
        metrics["margin"] = ChatTextView.elementsMargin
        metrics["maxHeight"] = ChatTextView.textViewMaxHeight

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[textView]-margin-[sendButton]-0-|",
            options: [.AlignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[textView(<=maxHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
    }

    private func setupUI() {
        clipsToBounds = true
        backgroundColor = UIColor.whiteColor()
        setRoundedCorners([.TopLeft, .BottomLeft], cornerRadius: LGUIKitConstants.defaultCornerRadius)
        setRoundedCorners([.TopRight, .BottomRight], cornerRadius: ChatTextView.minimumHeight/2)
        textView.tintColor = UIColor.primaryColor
        sendButton.setStyle(.Primary(fontSize: .Medium))
        sendButton.layer.borderWidth = 2
        sendButton.layer.borderColor = UIColor.whiteColor().CGColor
    }

    private func setupRX() {
        textView.rx_text.map { !$0.trim.isEmpty }.bindTo(sendButton.rx_enabled).addDisposableTo(disposeBag)
    }
}
