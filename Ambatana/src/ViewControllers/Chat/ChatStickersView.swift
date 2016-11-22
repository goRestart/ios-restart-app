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
}

class ChatStickersView: UIView {

    var enabled: Bool = true {
        didSet {
            if enabled {
                collectionView.deselectAll()
            }
        }
    }

    weak var delegate: ChatStickersViewDelegate?
    
    private var featureFlags: FeatureFlags
    private let collectionView: UICollectionView
    private var numberOfColumns: Int = 3
    private var stickers: [Sticker] = []

    convenience init() {
        self.init(featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(featureFlags: FeatureFlags) {
        let layout = UICollectionViewFlowLayout()
        self.featureFlags = featureFlags
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let initialFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        collectionView = UICollectionView(frame: initialFrame, collectionViewLayout: layout)
        super.init(frame: initialFrame)
        addSubview(collectionView)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor.whiteColor()
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        collectionView.registerClass(ChatStickerGridCell.self, forCellWithReuseIdentifier: ChatStickerGridCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func reloadStickers(stickers: [Sticker]) {
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ChatStickerGridCell.reuseIdentifier,
                                                                             forIndexPath: indexPath)
            guard let stickCell = cell as? ChatStickerGridCell else { return UICollectionViewCell() }
            guard let url = NSURL(string: stickers[indexPath.row].url) else { return UICollectionViewCell() }
            stickCell.imageView.image = nil
            stickCell.imageView.lg_setImageWithURL(url, placeholderImage: nil) { (result, url) in
                if let _ = result.error {
                    stickCell.imageView.image = UIImage(named: "sticker_error")
                }
            }
            return cell
    }

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return enabled
    }

    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return enabled
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if featureFlags.websocketChat {
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
        guard enabled else { return }
        let sticker = stickers[indexPath.row]
        delegate?.stickersViewDidSelectSticker(sticker)
    }

    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return enabled
    }
}

extension ChatStickersView: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = frame.width / CGFloat(numberOfColumns)
        return CGSize(width: width, height: width)
    }
}
