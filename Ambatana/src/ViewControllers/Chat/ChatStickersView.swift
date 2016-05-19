//
//  ChatStickersView.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ChatStickersView: UIView {
    let collectionView: UICollectionView
    var numberOfColumns: Int = 3
    var stickers: [Sticker] = []
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        super.init(frame: CGRectZero)
        addSubview(collectionView)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.greenColor()
        collectionView.backgroundColor = UIColor.purpleColor()
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        collectionView.registerClass(StickerCell.self, forCellWithReuseIdentifier: StickerCell.reuseIdentifier)
    }
    
    func showStickers(stickers: [Sticker]) {
        self.stickers = stickers
        collectionView.reloadData()
    }
}

extension ChatStickersView: UICollectionViewDataSource, UICollectionViewDelegate {
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
        imageView = UIImageView(frame: frame)
        super.init(frame: frame)
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        contentView.addSubview(imageView)
        backgroundColor = UIColor.blueColor()
        contentView.contentMode = .ScaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
