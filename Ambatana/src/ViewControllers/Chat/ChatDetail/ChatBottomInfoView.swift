//
//  ChatBottomInfoView.swift
//  LetGo
//
//  Created by Eli Kohen on 20/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct ChatBottomInfoViewData {
    let text: NSAttributedString
    let buttonText: String?
    let buttonAction: (()->Void)?
}

class ChatBottomInfoView: UIView {

    private let contentView = UIView()
    private let icon = UIImageView()
    private let label = UILabel()
    private let actionButton = UIButton(type: .Custom)

    let data: ChatBottomInfoViewData

    // MARK: - Lifecycle

    init(data: ChatBottomInfoViewData, frame: CGRect) {
        self.data = data
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        setupContent()
        setupIconAndLabel()
        setupButton()
    }

    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        let views = ["contentView": contentView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[contentView]-10-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[contentView]-10-|", options: [], metrics: nil, views: views))

        contentView.layer.borderWidth = StyleHelper.onePixelSize
        contentView.layer.borderColor = StyleHelper.backgroundColor.CGColor

        
    }

    private func setupIconAndLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
    }

    private func setupButton() {

    }
}
