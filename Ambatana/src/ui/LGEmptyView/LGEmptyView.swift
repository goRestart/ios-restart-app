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
    static let buttonHeight: CGFloat = 44
    static let contentBottomMargin: CGFloat = 16

    private let contentView: UIView = UIView()
    private let iconImageView: UIImageView = UIImageView()
    private var iconHeight: NSLayoutConstraint?
    private let titleLabel: UILabel = UILabel()
    private let bodyLabel: UILabel = UILabel()
    private var bodyButtonVSpacing: NSLayoutConstraint?
    private let actionButton: UIButton = UIButton()
    private var actionButtonHeight: NSLayoutConstraint?
    private var actionSecondaryButton: UIButton = UIButton(type: .System)
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

            if let body = body where !body.isEmpty {
                bodyButtonVSpacing?.constant = LGEmptyView.bodyButtonVSpacing
            } else {
                bodyButtonVSpacing?.constant = LGEmptyView.bodyButtonVSpacingBodyHidden
            }
        }
    }

    var buttonTitle: String? {
        didSet {
            actionButton.setTitle(buttonTitle, forState: .Normal)
            actionButtonHeight?.constant = buttonTitle != nil ? LGEmptyView.buttonHeight : 0
            updateConstraintsIfNeeded()
        }
    }
    
    var secondaryButtonTitle: String? {
        didSet {
            actionSecondaryButton.setTitle(secondaryButtonTitle, forState: .Normal)
            actionSecondaryButtonHeight?.constant = secondaryButtonTitle != nil ? LGEmptyView.buttonHeight : 0
            actionButtonBottomConstraint?.constant = secondaryButtonTitle != nil ? -LGEmptyView.titleBodyVSpacing : 0
            updateConstraintsIfNeeded()
        }
    }

    var action: (() -> ())?
    var secondaryAction: (() -> ())?

    func setupWithModel(model: LGEmptyViewModel) {
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

        contentView.layer.borderColor = UIColor.lineGray.CGColor
        contentView.layer.borderWidth = LGEmptyView.contentBorderWith
        contentView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        iconImageView.contentMode = .Center
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)

        titleLabel.font = UIFont.bigBodyFont
        titleLabel.textColor = UIColor.blackText
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        bodyLabel.font = UIFont.bigBodyFont
        bodyLabel.textColor = UIColor.darkGrayText
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .Center
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)

        actionButton.setStyle(.Primary(fontSize: .Medium))
        actionButton.titleLabel?.font = UIFont.mediumButtonFont
        actionButton.addTarget(self, action: #selector(LGEmptyView.actionButtonPressed), forControlEvents: .TouchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.accessibilityId = .EmptyViewPrimaryButton
        contentView.addSubview(actionButton)
        
        actionSecondaryButton.setStyle(.Secondary(fontSize: .Medium, withBorder: true))
        actionSecondaryButton.titleLabel?.font = UIFont.mediumButtonFont
        actionSecondaryButton.addTarget(self, action: #selector(LGEmptyView.secondaryActionButtonPressed), forControlEvents: .TouchUpInside)
        actionSecondaryButton.translatesAutoresizingMaskIntoConstraints = false
        actionSecondaryButton.accessibilityId = .EmptyViewSecondaryButton
        contentView.addSubview(actionSecondaryButton)
    }

    private func setupConstraints() {

        // Content view
        let centerYContent = NSLayoutConstraint(item: contentView, attribute: .CenterY, relatedBy: .Equal, toItem: self,
            attribute: .CenterY, multiplier: 1, constant: 0)
        addConstraint(centerYContent)
        let centerXContent = NSLayoutConstraint(item: contentView, attribute: .CenterX, relatedBy: .Equal, toItem: self,
            attribute: .CenterX, multiplier: 1, constant: 0)
        addConstraint(centerXContent)
        let widthContent = NSLayoutConstraint(item: contentView, attribute: .Width, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: LGEmptyView.contentViewWidth)
        contentView.addConstraint(widthContent)

        // Content horizontal
        // > Icon
        var views = [String: AnyObject]()
        views["icon"] = iconImageView
        var metrics = [String: AnyObject]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let centerXIcon = NSLayoutConstraint(item: iconImageView, attribute: .CenterX, relatedBy: .Equal,
            toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)
        contentView.addConstraint(centerXIcon)
        let hIcon = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hMargin-[icon]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hIcon)

        // > Title
        views = [String: AnyObject]()
        views["title"] = titleLabel
        metrics = [String: AnyObject]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let hTitle = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hMargin-[title]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hTitle)

        // > Body
        views = [String: AnyObject]()
        views["body"] = bodyLabel
        metrics = [String: AnyObject]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let hBody = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hMargin-[body]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hBody)

        // > Button
        views = [String: AnyObject]()
        views["button"] = actionButton
        metrics = [String: AnyObject]()
        metrics["hMargin"] = LGEmptyView.contentHMargin

        let hButton = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hMargin-[button]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hButton)
        
        // > Secondary Button
        views = [String: AnyObject]()
        views["secondaryButton"] = actionSecondaryButton
        metrics = [String: AnyObject]()
        metrics["hMargin"] = LGEmptyView.contentHMargin
        
        let hSecondaryButton = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hMargin-[secondaryButton]-hMargin-|",
            options: [], metrics: metrics, views: views)
        contentView.addConstraints(hSecondaryButton)

        
        // Content vertical
        views = [String: AnyObject]()
        views["icon"] = iconImageView
        views["body"] = bodyLabel
        views["title"] = titleLabel
        views["button"] = actionButton
        views["secondaryButton"] = actionSecondaryButton
        metrics = [String: AnyObject]()
        metrics["topM"] = LGEmptyView.contentTopMargin
        metrics["iconTitleS"] = LGEmptyView.iconTitleVSpacing
        metrics["titleBodyS"] = LGEmptyView.titleBodyVSpacing
        metrics["bottomM"] = LGEmptyView.contentBottomMargin

        let format1 = "V:|-topM-[icon]-iconTitleS-[title]-titleBodyS-[body]"
        let vContent1 = NSLayoutConstraint.constraintsWithVisualFormat(format1, options: [], metrics: metrics,
            views: views)
        contentView.addConstraints(vContent1)

        let bodyButtonVSpacingConstraint = NSLayoutConstraint(item: actionButton, attribute: .Top, relatedBy: .Equal,
            toItem: bodyLabel, attribute: .Bottom, multiplier: 1, constant: LGEmptyView.bodyButtonVSpacing)
        contentView.addConstraint(bodyButtonVSpacingConstraint)
        bodyButtonVSpacing = bodyButtonVSpacingConstraint

        let format2 = "V:[secondaryButton]-bottomM-|"
        
        let vContent2 = NSLayoutConstraint.constraintsWithVisualFormat(format2, options: [], metrics: metrics,
            views: views)
        contentView.addConstraints(vContent2)

        actionButtonBottomConstraint = NSLayoutConstraint(item: actionButton, attribute: .Bottom, relatedBy: .Equal,
            toItem: actionSecondaryButton, attribute: .Top, multiplier: 1, constant: -LGEmptyView.titleBodyVSpacing)
        if let actionButtonBottomConstraint = actionButtonBottomConstraint {
            contentView.addConstraint(actionButtonBottomConstraint)
        }
        
        // > Icon height
        iconHeight = NSLayoutConstraint(item: iconImageView, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: icon?.size.height ?? 0)
        if let iconHeight = iconHeight {
            iconImageView.addConstraint(iconHeight)
        }

        // > Button height
        actionButtonHeight = NSLayoutConstraint(item: actionButton, attribute: .Height, relatedBy: .Equal, toItem: nil,
            attribute: .NotAnAttribute, multiplier: 1, constant: buttonTitle != nil ? LGEmptyView.buttonHeight : 0)
        if let actionButtonHeight = actionButtonHeight {
            actionButton.addConstraint(actionButtonHeight)
        }
        
        // > Secondary Button height
        actionSecondaryButtonHeight = NSLayoutConstraint(item: actionSecondaryButton, attribute: .Height, relatedBy:
            .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant:
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
