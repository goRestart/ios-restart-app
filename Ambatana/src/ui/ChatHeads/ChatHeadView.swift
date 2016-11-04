//
//  ChatHeadView.swift
//  LetGo
//
//  Created by Albert Hernández López on 03/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

final class ChatHeadView: UIView {
    var id: String {
        return data.id
    }
    private let data: ChatHeadData
    private let avatarImageView: UIImageView


    // MARK: - Lifecycle

    convenience init(data: ChatHeadData) {
        self.init(frame: CGRect.zero, data: data)
    }

    init(frame: CGRect, data: ChatHeadData) {
        self.data = data
        self.avatarImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        updateImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
}


// MARK: - Private methods

private extension ChatHeadView {
    func setupUI() {
        clipsToBounds = false
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 0.24
        layer.shadowRadius = 2.0

        avatarImageView.clipsToBounds = true
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.white.CGColor

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarImageView)
    }

    func setupConstraints() {
        let views: [String: AnyObject] = ["aiv": avatarImageView]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[aiv]-0-|",
                                                                          options: [], metrics: nil, views: views)
        addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[aiv]-0-|",
                                                                          options: [], metrics: nil, views: views)
        addConstraints(vConstraints)
    }

    func updateImage() {
        avatarImageView.image = data.placeholder

        guard let imageURL = data.imageURL else { return }
        ImageDownloader.sharedInstance.downloadImageWithURL(imageURL) { [weak self] result, url in
            guard let imageWithSource = result.value where url == imageURL else { return }
            self?.avatarImageView.image = imageWithSource.image
        }
    }
}
