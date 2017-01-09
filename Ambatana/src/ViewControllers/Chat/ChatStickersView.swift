//
//  ChatStickersView.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatStickersViewDelegate: class {
    func stickersViewDidSelectSticker(_ sticker: Sticker)
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
    
    fileprivate var featureFlags: FeatureFlaggeable
    fileprivate let collectionView: UICollectionView
    fileprivate var numberOfColumns: Int = 3
    fileprivate var stickers: [Sticker] = []

    convenience init() {
        self.init(featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(featureFlags: FeatureFlaggeable) {
        let layout = UICollectionViewFlowLayout()
        self.featureFlags = featureFlags
        layout.scrollDirection = .vertical
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
        backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(ChatStickerGridCell.self, forCellWithReuseIdentifier: ChatStickerGridCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func reloadStickers(_ stickers: [Sticker]) {
        self.stickers = stickers
        collectionView.reloadData()
    }
}

extension ChatStickersView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatStickerGridCell.reuseIdentifier,
                                                                             for: indexPath)
            guard let stickCell = cell as? ChatStickerGridCell else { return UICollectionViewCell() }
            guard let url = URL(string: stickers[indexPath.row].url) else { return UICollectionViewCell() }
            stickCell.imageView.image = nil
            stickCell.imageView.lg_setImageWithURL(url, placeholderImage: nil) { (result, url) in
                if let _ = result.error {
                    stickCell.imageView.image = UIImage(named: "sticker_error")
                }
            }
            return cell
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return enabled
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return enabled
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if featureFlags.websocketChat {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard enabled else { return }
        let sticker = stickers[indexPath.row]
        delegate?.stickersViewDidSelectSticker(sticker)
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return enabled
    }
}

extension ChatStickersView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = frame.width / CGFloat(numberOfColumns)
        return CGSize(width: width, height: width)
    }
}
