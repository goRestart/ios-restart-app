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
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    static let backgroundWithImageTop: CGFloat = 25
    static let titleVisibleTop: CGFloat = 67
    static let titleInvisibleTop: CGFloat = 8
    static let buttonVisibleHeight: CGFloat = 30
    static let buttonVisibleBottom: CGFloat = 8
    static let buttonHContentInset: CGFloat = 16

    var buttonAction: (() -> Void)?
    let disposeBag = DisposeBag()


    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRxBindings()
        setAccessibilityIds()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.setStyle(.primary(fontSize: .small))
    }
}


// MARK: - Public methods

extension ChatDisclaimerCell {
    func showAvatar(_ show: Bool) {
        hideImageAndTitle(!show)
    }

    func setMessage(_ message: NSAttributedString) {
        messageLabel.attributedText = message
    }

    func setButton(title: String?) {
        button.setTitle(title, for: UIControlState())
        hideButton(title == nil || button.isHidden)
    }

    func setButton(action: (() -> Void)?) {
        buttonAction = action
        hideButton(action == nil || button.isHidden)
    }
}


// MARK: - Private methods

fileprivate extension ChatDisclaimerCell {
    func setupUI() {
        backgroundCellView.layer.cornerRadius = LGUIKitConstants.chatCellCornerRadius
        backgroundCellView.backgroundColor = UIColor.disclaimerColor
        backgroundCellView.layer.borderWidth = 1
        backgroundCellView.layer.borderColor = UIColor.white.cgColor

        messageLabel.textColor = UIColor.darkGrayText
        messageLabel.font = UIFont.bigBodyFont
        button.setStyle(.primary(fontSize: .small))
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: ChatDisclaimerCell.buttonHContentInset,
                                                bottom: 0, right: ChatDisclaimerCell.buttonHContentInset)

        backgroundColor = UIColor.clear
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    func setupRxBindings() {
        button.rx.tap.asObservable().subscribeNext { [weak self] _ in
            self?.buttonAction?()
        }.addDisposableTo(disposeBag)
    }
    
    dynamic func tapped() {
        buttonAction?()
    }

    func hideImageAndTitle(_ hide: Bool) {
        backgroundTopConstraint?.constant = hide ? 0 : ChatDisclaimerCell.backgroundWithImageTop
        titleTopConstraint?.constant = hide ? ChatDisclaimerCell.titleInvisibleTop : ChatDisclaimerCell.titleVisibleTop
        avatarImageView.isHidden = hide
        titleLabel.text = hide ? nil : LGLocalizedString.chatDisclaimerLetgoTeam
    }
    
    func hideButton(_ hide: Bool) {
        buttonHeightConstraint?.constant = hide ? 0 : ChatDisclaimerCell.buttonVisibleHeight
        buttonBottomConstraint?.constant = hide ? 0 : ChatDisclaimerCell.buttonVisibleBottom
        button.isHidden = hide
    }
}

extension ChatDisclaimerCell {
    func setAccessibilityIds() {
        messageLabel.accessibilityId = .chatDisclaimerCellMessageLabel
        button.accessibilityId = .chatDisclaimerCellButton
    }
}
