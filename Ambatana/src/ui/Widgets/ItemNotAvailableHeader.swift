//
//  ItemNotAvailableHeader.swift
//  LetGo
//
//  Created by Dídac on 17/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

class ItemNotAvailableHeader: UIView {

    static let viewHeight: CGFloat = 130
    private static let headerMargin: CGFloat = 10
    private static let iconWidth: CGFloat = 70
    private static let itemsMargin: CGFloat = 25


    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.clear

        let container = UIView()
        container.backgroundColor = UIColor.white
        container.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        let label = UILabel()
        label.font = UIFont.systemBoldFont(size: 23)
        label.numberOfLines = 0
        label.textColor = UIColor.blackText
        label.textAlignment = .left
        label.text = LGLocalizedString.commonProductNotAvailable
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        let icon = UIImageView(image: UIImage(named: "ic_emoji_no"))
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)

        container.layout(with: self).center()
        container.layout(with: self).top(by: ItemNotAvailableHeader.headerMargin)
            .bottom()
            .left(by: ItemNotAvailableHeader.headerMargin)
            .right(by: -ItemNotAvailableHeader.headerMargin)

        label.layout(with: container).top(by: ItemNotAvailableHeader.itemsMargin)
            .bottom(by: -ItemNotAvailableHeader.itemsMargin)
        label.layout(with: container).centerY()
        label.layout(with: container).left(by: ItemNotAvailableHeader.itemsMargin)
        label.layout(with: icon).trailing(to: .leading, by: -ItemNotAvailableHeader.itemsMargin)

        icon.layout().width(ItemNotAvailableHeader.iconWidth).height(ItemNotAvailableHeader.iconWidth)
        icon.layout(with: container).centerY()
        icon.layout(with: container).right(by: -ItemNotAvailableHeader.itemsMargin)
    }
}
