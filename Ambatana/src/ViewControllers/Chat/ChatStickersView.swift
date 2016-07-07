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
            collectionView.scrollEnabled = enabled
            if enabled {
                reEnableCells()
            }
        }
    }

    weak var delegate: ChatStickersViewDelegate?

    private let collectionView: UICollectionView
    private var numberOfColumns: Int = 3
    private var stickers: [Sticker] = []

    init() {
        let layout = UICollectionViewFlowLayout()
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

    private func reEnableCells() {
        collectionView.visibleCells().forEach { cell in
            guard let cell = cell as? ChatStickerGridCell else { return }
            cell.setCellHighlighted(false)
        }
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard enabled else { return }
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ChatStickerGridCell {
            cell.setCellHighlighted(true)
        }
        let sticker = stickers[indexPath.row]
        delegate?.stickersViewDidSelectSticker(sticker)
    }

    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        guard enabled else { return }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ChatStickerGridCell else { return }
        cell.setCellHighlighted(true)
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        guard enabled else { return }
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ChatStickerGridCell else { return }
        cell.setCellHighlighted(false)
    }
}

extension ChatStickersView: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = frame.width / CGFloat(numberOfColumns)
        return CGSize(width: width, height: width)
    }
}
