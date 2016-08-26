//
//  ChatAlertView.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class ChatDisclaimerCell: UITableViewCell, ReusableCell {
    
    @IBOutlet weak var backgroundCellView: UIView!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!
    
    private static let buttonVisibleHeight: CGFloat = 30
    private static let buttonVisibleBottom: CGFloat = 8
    private static let buttonHContentInset: CGFloat = 16

    private var buttonAction: (() -> Void)?
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRxBindings()
        setAccessibilityIds()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.setStyle(.Primary(fontSize: .Small))
    }
}


// MARK: - Public methods

extension ChatDisclaimerCell {
    func setMessage(message: NSAttributedString) {
        messageLabel.attributedText = message
    }

    func setButton(title title: String?) {
        button.setTitle(title, forState: .Normal)
        hideButton(title == nil || button.hidden)
    }

    func setButton(action action: (() -> Void)?) {
        buttonAction = action
        hideButton(action == nil || button.hidden)
    }
}


// MARK: - Private methods

private extension ChatDisclaimerCell {
    func setupUI() {
        backgroundCellView.layer.cornerRadius = LGUIKitConstants.chatCellCornerRadius
        backgroundCellView.backgroundColor = UIColor.disclaimerColor

        messageLabel.textColor = UIColor.darkGrayText
        messageLabel.font = UIFont.bigBodyFont
        button.setStyle(.Primary(fontSize: .Small))
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: ChatDisclaimerCell.buttonHContentInset,
                                                bottom: 0, right: ChatDisclaimerCell.buttonHContentInset)

        backgroundColor = UIColor.clearColor()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func setupRxBindings() {
        button.rx_tap.asObservable().subscribeNext { [weak self] _ in
            self?.buttonAction?()
        }.addDisposableTo(disposeBag)
    }
    
    dynamic func tapped() {
        buttonAction?()
    }
    
    func hideButton(hide: Bool) {
        buttonHeightConstraint?.constant = hide ? 0 : ChatDisclaimerCell.buttonVisibleHeight
        buttonBottomConstraint?.constant = hide ? 0 : ChatDisclaimerCell.buttonVisibleBottom
        button.hidden = hide
    }
}

extension ChatDisclaimerCell {
    func setAccessibilityIds() {
        messageLabel.accessibilityId = .ChatDisclaimerCellMessageLabel
        button.accessibilityId = .ChatDisclaimerCellButton
    }
}
