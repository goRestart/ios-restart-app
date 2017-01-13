//
//  ChatStickerCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class ChatStickerGridCell: UICollectionViewCell {
    let imageView: UIImageView
    static let reuseIdentifier = "StickerCell"
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            refreshState()
        }
    }

    override var isSelected: Bool {
        didSet {
            refreshState()
        }
    }

    private func refreshState() {
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.alpha = highlighedState ? 0.6 : 1
    }
}
