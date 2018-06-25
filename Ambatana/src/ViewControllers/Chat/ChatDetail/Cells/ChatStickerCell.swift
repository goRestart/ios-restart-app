//
//  ChatStickerCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


final class ChatStickerCell: UITableViewCell, ReusableCell {
    
    let leftImage = UIImageView()
    let rightImage = UIImageView()

    private struct Layout {
        static let imageSize = CGSize(width: 125, height: 125)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubviewsForAutoLayout([leftImage, rightImage])
        leftImage.contentMode = .scaleAspectFit
        rightImage.contentMode = .scaleAspectFit
    }

    private func setupConstraints() {
        let constraints = [
            leftImage.widthAnchor.constraint(equalToConstant: Layout.imageSize.width),
            leftImage.heightAnchor.constraint(equalToConstant: Layout.imageSize.height),
            rightImage.widthAnchor.constraint(equalToConstant: Layout.imageSize.width),
            rightImage.heightAnchor.constraint(equalToConstant: Layout.imageSize.height),
            leftImage.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            leftImage.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            leftImage.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            rightImage.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            rightImage.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            rightImage.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setAccessibilityIds() {
        set(accessibilityId: .chatStickerCellContainer)
        leftImage.set(accessibilityId: .chatStickerCellLeftImage)
        rightImage.set(accessibilityId: .chatStickerCellRightImage)
    }

    private func resetUI() {
        leftImage.image = nil
        rightImage.image = nil
    }
}

