//
//  LGEmptyView.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

@IBDesignable class LGEmptyView: UIView {

    static let contentViewHMargin = 24
    static let contentHMargin = 24

    static let contentTopMargin = 40
    static let iconTitleVSpacing = 16
    static let titleBodyVSpacing = 10
    static let bodyButtonVSpacing = 44
    static let buttonHeight: CGFloat = 44
    static let contentBottomMargin = 24

    private let contentView: UIView = UIView()
    private let iconImageView: UIImageView = UIImageView()
    private var iconHeight: NSLayoutConstraint?
    private let titleLabel: UILabel = UILabel()
    private let bodyLabel: UILabel = UILabel()
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


    // MARK: - Private methods

    private func setupUI() {
        if let patternImage = UIImage(named: "placeholder_pattern") {
            backgroundColor = UIColor(patternImage: patternImage)
        }

        contentView.layer.borderColor = StyleHelper.lineColor.CGColor
        contentView.layer.borderWidth = 0.5
        contentView.layer.cornerRadius = 4
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        iconImageView.contentMode = .Center
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconImageView)

        titleLabel.font = UIFont.systemFontOfSize(17)
        titleLabel.textColor = UIColor(rgb: 0x2C2C2C)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        bodyLabel.font = UIFont.systemFontOfSize(17)
        bodyLabel.textColor = UIColor(rgb: 0x757575)
        bodyLabel.numberOfLines = 2
        bodyLabel.textAlignment = .Center
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyLabel)

        actionButton.titleLabel?.textAlignment = .Center
        actionButton.titleLabel?.font = UIFont.systemFontOfSize(18)
        actionButton.titleLabel?.textColor = UIColor.whiteColor()
        actionButton.setBackgroundImage(StyleHelper.primaryColor.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        actionButton.addTarget(self, action: "actionButtonPressed", forControlEvents: .TouchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionButton)


    }

    private func setupConstraints() {

        // Content view
        var views = [String: AnyObject]()
        views["content"] = contentView
        var metrics = [String: AnyObject]()
        metrics["hMargin"] = LGEmptyView.contentViewHMargin

        let centerYContent = NSLayoutConstraint(item: contentView, attribute: .CenterY, relatedBy: .Equal, toItem: self,
            attribute: .CenterY, multiplier: 1, constant: 0)
        addConstraint(centerYContent)
        let hContent = NSLayoutConstraint.constraintsWithVisualFormat("H:|-hMargin-[content]-hMargin-|",
            options: [], metrics: metrics, views: views)
        addConstraints(hContent)

        // Content horizontal
        // > Icon
        views = [String: AnyObject]()
        views["icon"] = iconImageView
        metrics = [String: AnyObject]()
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
        metrics["bodyButtonS"] = LGEmptyView.bodyButtonVSpacing
        metrics["bottomM"] = LGEmptyView.contentBottomMargin

        let format = "V:|-topM-[icon]-iconTitleS-[title]-titleBodyS-[body]-bodyButtonS-[button]-bottomM-|"
        let vContent = NSLayoutConstraint.constraintsWithVisualFormat(format, options: [], metrics: metrics,
            views: views)
        contentView.addConstraints(vContent)

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
