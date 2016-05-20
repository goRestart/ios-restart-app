//
//  ChatStickersView.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatStickersViewDelegate: class {
    func stickersViewDidSelectSticker(sticker: Sticker)
    func stickersViewDidPressKeyboardButton()
}

class ChatStickersView: UIView {
    let collectionView: UICollectionView
    var headerView: UIView
    var numberOfColumns: Int = 3
    var stickers: [Sticker] = []
    let keyboardButton: UIButton
    var textView: UITextView
    let separatorView: UIView
    weak var delegate: ChatStickersViewDelegate?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let initialFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        collectionView = UICollectionView(frame: initialFrame, collectionViewLayout: layout)
        keyboardButton = UIButton(frame: CGRect(x: 8, y: 11, width: 22, height: 22))
        textView = UITextView(frame: CGRect(x: 38, y: 5, width: 100-5-38, height: 34))
        separatorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 1))
        super.init(frame: initialFrame)
        addSubview(collectionView)
        addSubview(headerView)
        headerView.addSubview(keyboardButton)
        headerView.addSubview(textView)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        collectionView.registerClass(StickerCell.self, forCellWithReuseIdentifier: StickerCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        headerView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        headerView.backgroundColor = UIColor.whiteColor()
        
        keyboardButton.autoresizingMask = [.FlexibleRightMargin]
        keyboardButton.setImage(UIImage(named: "ic_chat_keyboard"), forState: .Normal)
        keyboardButton.addTarget(self, action: #selector(didTapKeyboardButton), forControlEvents: .TouchUpInside)
        
        textView.autoresizingMask = [.FlexibleWidth]
        textView.layer.borderColor = UIColor(rgb: 0xC8C8CD).CGColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = StyleHelper.defaultCornerRadius
    
        separatorView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        separatorView.backgroundColor = StyleHelper.lineColor
    }
    
    func didTapKeyboardButton() {
        delegate?.stickersViewDidPressKeyboardButton()
    }
    
    func showStickers(stickers: [Sticker]) {
        self.stickers = stickers
        collectionView.reloadData()
    }
}

extension ChatStickersView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StickerCell.reuseIdentifier,
                                                                             forIndexPath: indexPath)
            guard let stickCell = cell as? StickerCell else { return UICollectionViewCell() }
            guard let url = NSURL(string: stickers[indexPath.row].url) else { return UICollectionViewCell() }
            stickCell.imageView.lg_setImageWithURL(url)
            return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let sticker = stickers[indexPath.row]
        delegate?.stickersViewDidSelectSticker(sticker)
    }
}

extension ChatStickersView: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = frame.width / CGFloat(numberOfColumns)
        return CGSize(width: width, height: width)
    }
}

class StickerCell: UICollectionViewCell {
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
}
