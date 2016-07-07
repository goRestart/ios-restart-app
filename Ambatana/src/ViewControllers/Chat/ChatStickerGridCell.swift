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
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageView.contentMode = .ScaleAspectFit
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCellHighlighted(highlighted: Bool) {
        contentView.alpha = highlighted ? 0.6 : 1
    }
}
