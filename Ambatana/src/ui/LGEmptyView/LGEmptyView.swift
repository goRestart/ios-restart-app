//
//  LGEmptyView.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

@IBDesignable class LGEmptyView: UIView {

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

    @IBInspectable var icon: UIImage? {
        didSet {
            iconImageView.image = icon
            iconHeight?.constant = icon?.size.height ?? 0
            updateConstraintsIfNeeded()
        }
    }

    @IBInspectable var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    @IBInspectable var body: String? {
        didSet {
            bodyLabel.text = body

            if let body = body where !body.isEmpty {
                bodyButtonVSpacing?.constant = LGEmptyView.bodyButtonVSpacing
            } else {
                bodyButtonVSpacing?.constant = LGEmptyView.bodyButtonVSpacingBodyHidden
            }
        }
    }

    @IBInspectable var buttonTitle: String? {
        didSet {
            actionButton.setTitle(buttonTitle, forState: .Normal)
            actionButtonHeight?.constant = buttonTitle != nil ? LGEmptyView.buttonHeight : 0
            updateConstraintsIfNeeded()
        }
    }

    var action: (() -> ())?

    func setupWithModel(model: LGEmptyViewModel) {
        icon = model.icon
        title = model.title
        body = model.body
        buttonTitle = model.buttonTitle
        action = model.action
    }


    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = StyleHelper.emptyViewBackgroundColor

        contentView.layer.borderColor = StyleHelper.lineColor.CGColor
        contentView.layer.borderWidth = StyleHelper.emptyViewContentBorderWith
        contentView.layer.cornerRadius = StyleHelper.emptyViewContentBorderRadius
        contentView.backgroundColor = StyleHelper.emptyViewContentBackgroundColor
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        iconImageView.contentMode = .Center
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)

        titleLabel.font = StyleHelper.emptyViewTitleFont
        titleLabel.textColor = StyleHelper.emptyViewTitleColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        bodyLabel.font = StyleHelper.emptyViewBodyFont
        bodyLabel.textColor = StyleHelper.emptyViewBodyColor
        bodyLabel.numberOfLines = 0
        bodyLabel.textAlignment = .Center
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)

        actionButton.setPrimaryStyle()
        actionButton.titleLabel?.font = StyleHelper.emptyViewActionButtonFont
        actionButton.titleLabel?.textColor = StyleHelper.emptyViewActionButtonColor
        actionButton.addTarget(self, action: "actionButtonPressed", forControlEvents: .TouchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionButton)
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

        // Content vertical
        views = [String: AnyObject]()
        views["icon"] = iconImageView
        views["body"] = bodyLabel
        views["title"] = titleLabel
        views["button"] = actionButton
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


        let format2 = "V:[button]-bottomM-|"
        let vContent2 = NSLayoutConstraint.constraintsWithVisualFormat(format2, options: [], metrics: metrics,
            views: views)
        contentView.addConstraints(vContent2)


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
    }

    dynamic private func actionButtonPressed() {
        action?()
    }
}
