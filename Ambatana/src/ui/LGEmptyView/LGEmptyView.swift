//
//  LGEmptyView.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class LGEmptyView: UIView {

    static let contentBorderWith: CGFloat = 0.5
    static let contentViewHMargin: CGFloat = 24
    static let contentViewWidth: CGFloat = 270

    static let contentHMargin: CGFloat = 16
    static let contentTopMargin: CGFloat = 16
    static let iconTitleVSpacing: CGFloat = 16
    static let titleBodyVSpacing: CGFloat = 10
    static let bodyButtonVSpacing: CGFloat = 44
    static let bodyButtonVSpacingBodyHidden: CGFloat = 20
    static let buttonHeight: CGFloat = 50
    static let contentBottomMargin: CGFloat = 16

    private let contentView: UIView = UIView()
    private let iconImageView: UIImageView = UIImageView()
    private var iconHeight: NSLayoutConstraint?
    private let titleLabel: UILabel = UILabel()
    private let bodyLabel: UILabel = UILabel()
    private var bodyButtonVSpacing: NSLayoutConstraint?
    private let actionButton: UIButton = UIButton(type: .custom)
    private var actionButtonHeight: NSLayoutConstraint?
    private var actionSecondaryButton: UIButton = UIButton(type: .custom)
    private var actionSecondaryButtonHeight: NSLayoutConstraint?
    private var actionButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        setupConstraints()
    }


    // MARK: - Public methods

    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
            iconHeight?.constant = icon?.size.height ?? 0
            updateConstraintsIfNeeded()
        }
    }

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var body: String? {
        didSet {
            bodyLabel.text = body

            if let body = body, !body.isEmpty {
                bodyButtonVSpacing?.constant = LGEmptyView.bodyButtonVSpacing
            } else {
                bodyButtonVSpacing?.constant = LGEmptyView.bodyButtonVSpacingBodyHidden
            }
        }
    }

    var buttonTitle: String? {
        didSet {
            actionButton.setTitle(buttonTitle, for: UIControlState())
            actionButtonHeight?.constant = buttonTitle != nil ? LGEmptyView.buttonHeight : 0
            updateConstraintsIfNeeded()
        }
    }
    
    var secondaryButtonTitle: String? {
        didSet {
            actionSecondaryButton.setTitle(secondaryButtonTitle, for: UIControlState())
            actionSecondaryButtonHeight?.constant = secondaryButtonTitle != nil ? LGEmptyView.buttonHeight : 0
            actionButtonBottomConstraint?.constant = secondaryButtonTitle != nil ? -LGEmptyView.titleBodyVSpacing : 0
            updateConstraintsIfNeeded()
        }
    }

    var action: (() -> ())?
    var secondaryAction: (() -> ())?

    func setupWithModel(_ model: LGEmptyViewModel) {
        icon = model.icon
        title = model.title
        body = model.body
        buttonTitle = model.buttonTitle
        action = model.action
        secondaryButtonTitle = model.secondaryButtonTitle
        secondaryAction = model.secondaryAction
    }


    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.emptyViewBackgroundColor

        contentView.layer.borderColor = UIColor.lineGray.cgColor
        contentView.layer.borderWidth = LGEmptyView.contentBorderWith
        contentView.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        iconImageView.contentMode = .center
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)

        titleLabel.font = UIFont.bigBodyFont
        titleLabel.textColor = UIColor.blackText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        bodyLabel.font = UIFont.bigBodyFont
        bodyLabel.textColor = UIColor.darkGrayText
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .center
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)

        // initial frame so it can calculate the button corner radius
        actionButton.frame = CGRect(x: 0, y: 0, width: 10, height: LGEmptyView.buttonHeight)
        actionButton.setStyle(.primary(fontSize: .medium))
        actionButton.titleLabel?.font = UIFont.mediumButtonFont
        actionButton.addTarget(self, action: #selector(LGEmptyView.actionButtonPressed), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.accessibilityId = .emptyViewPrimaryButton
        contentView.addSubview(actionButton)
        
        // initial frame so it can calculate the button corner radius
        actionSecondaryButton.frame = CGRect(x: 0, y: 0, width: 10, height: LGEmptyView.buttonHeight)
        actionSecondaryButton.setStyle(.secondary(fontSize: .medium, withBorder: true))
        actionSecondaryButton.titleLabel?.font = UIFont.mediumButtonFont
        actionSecondaryButton.addTarget(self, action: #selector(LGEmptyView.secondaryActionButtonPressed), for: .touchUpInside)
        actionSecondaryButton.translatesAutoresizingMaskIntoConstraints = false
        actionSecondaryButton.accessibilityId = .emptyViewSecondaryButton
        contentView.addSubview(actionSecondaryButton)
    }

    private func setupConstraints() {

        // Content view
        let centerYContent = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self,
            attribute: .centerY, multiplier: 1, constant: 0)
        addConstraint(centerYContent)
        let centerXContent = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: self,
            attribute: .centerX, multiplier: 1, constant: 0)
        addConstraint(centerXContent)
        let widthContent = NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: LGEmptyView.contentViewWidth)
        contentView.addConstraint(widthContent)

        // Content horizontal
        // > Icon
        var views = [String: Any]()
        views["icon"] = iconImageView
        var metrics = [String: Any]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let centerXIcon = NSLayoutConstraint(item: iconImageView, attribute: .centerX, relatedBy: .equal,
            toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        contentView.addConstraint(centerXIcon)
        let hIcon = NSLayoutConstraint.constraints(withVisualFormat: "H:|-hMargin-[icon]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hIcon)

        // > Title
        views = [String: Any]()
        views["title"] = titleLabel
        metrics = [String: Any]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let hTitle = NSLayoutConstraint.constraints(withVisualFormat: "H:|-hMargin-[title]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hTitle)

        // > Body
        views = [String: Any]()
        views["body"] = bodyLabel
        metrics = [String: Any]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let hBody = NSLayoutConstraint.constraints(withVisualFormat: "H:|-hMargin-[body]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hBody)

        // > Button
        views = [String: Any]()
        views["button"] = actionButton
        metrics = [String: Any]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let hButton = NSLayoutConstraint.constraints(withVisualFormat: "H:|-hMargin-[button]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hButton)
        
        // > Secondary Button
        views = [String: Any]()
        views["secondaryButton"] = actionSecondaryButton
        metrics = [String: Any]()
        metrics["hMargin"] = LGEmptyView.contentHMargin
        
        let hSecondaryButton = NSLayoutConstraint.constraints(withVisualFormat: "H:|-hMargin-[secondaryButton]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hSecondaryButton)

        
        // Content vertical
        views = [String: Any]()
        views["icon"] = iconImageView
        views["body"] = bodyLabel
        views["title"] = titleLabel
        views["button"] = actionButton
        views["secondaryButton"] = actionSecondaryButton
        metrics = [String: Any]()
        metrics["topM"] = LGEmptyView.contentTopMargin
        metrics["iconTitleS"] = LGEmptyView.iconTitleVSpacing
        metrics["titleBodyS"] = LGEmptyView.titleBodyVSpacing
        metrics["bottomM"] = LGEmptyView.contentBottomMargin

        let format1 = "V:|-topM-[icon]-iconTitleS-[title]-titleBodyS-[body]"
        let vContent1 = NSLayoutConstraint.constraints(withVisualFormat: format1, options: [], metrics: metrics,
            views: views)
        contentView.addConstraints(vContent1)

        let bodyButtonVSpacingConstraint = NSLayoutConstraint(item: actionButton, attribute: .top, relatedBy: .equal,
            toItem: bodyLabel, attribute: .bottom, multiplier: 1, constant: LGEmptyView.bodyButtonVSpacing)
        contentView.addConstraint(bodyButtonVSpacingConstraint)
        bodyButtonVSpacing = bodyButtonVSpacingConstraint

        let format2 = "V:[secondaryButton]-bottomM-|"
        
        let vContent2 = NSLayoutConstraint.constraints(withVisualFormat: format2, options: [], metrics: metrics,
            views: views)
        contentView.addConstraints(vContent2)

        actionButtonBottomConstraint = NSLayoutConstraint(item: actionButton, attribute: .bottom, relatedBy: .equal,
            toItem: actionSecondaryButton, attribute: .top, multiplier: 1, constant: -LGEmptyView.titleBodyVSpacing)
        if let actionButtonBottomConstraint = actionButtonBottomConstraint {
            contentView.addConstraint(actionButtonBottomConstraint)
        }
        
        // > Icon height
        iconHeight = NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: icon?.size.height ?? 0)
        if let iconHeight = iconHeight {
            iconImageView.addConstraint(iconHeight)
        }

        // > Button height
        actionButtonHeight = NSLayoutConstraint(item: actionButton, attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: buttonTitle != nil ? LGEmptyView.buttonHeight : 0)
        if let actionButtonHeight = actionButtonHeight {
            actionButton.addConstraint(actionButtonHeight)
        }
        
        // > Secondary Button height
        actionSecondaryButtonHeight = NSLayoutConstraint(item: actionSecondaryButton, attribute: .height, relatedBy:
            .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant:
            secondaryButtonTitle != nil ? LGEmptyView.buttonHeight : 0)
        if let actionButtonHeight = actionSecondaryButtonHeight {
            actionSecondaryButton.addConstraint(actionButtonHeight)
        }
    }

    dynamic private func actionButtonPressed() {
        action?()
    }
    
    dynamic private func secondaryActionButtonPressed() {
        secondaryAction?()
    }
}
