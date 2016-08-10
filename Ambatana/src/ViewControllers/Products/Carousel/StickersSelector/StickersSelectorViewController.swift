//
//  StickersSelectorViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 10/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol StickersSelectorDelegate: class {
    func stickersSelectorDidSelectSticker(sticker: Sticker)
    func stickersSelectorDidCancel()
}

class StickersSelectorViewController: BaseViewController {

    @IBOutlet weak var blurContainer: UIVisualEffectView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    weak var delegate: StickersSelectorDelegate?

    private let itemsMargin: CGFloat = 15
    private let stickerMaxHeight: CGFloat = 126

    private let stickers: [Sticker]
    private let interlocutorName: String?


    // MARK: - Lifecycle

    init(stickers: [Sticker], interlocutorName: String?) {
        self.stickers = stickers
        self.interlocutorName = interlocutorName
        super.init(viewModel: nil, nibName: "StickersSelectorViewController")
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        buildStickers()
    }

    override func viewDidFirstAppear(animated: Bool) {
        super.viewDidFirstAppear(animated)

        buildStickers()
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.delegate?.stickersSelectorDidCancel()
        }
    }


    // MARK: - Private

    private func setupUI() {
        if let interlocutorName = interlocutorName where !interlocutorName.isEmpty {
            titleLabel.text = LGLocalizedString.productStickersSelectionWName(interlocutorName)
        } else {
            titleLabel.text = LGLocalizedString.productStickersSelectionWoName
        }
    }

    private func buildStickers() {
        let count = stickers.count < 4 ? stickers.count : 4
        let screenSpace = (closeButton.frame.top - itemsMargin) - (titleLabel.bottom + itemsMargin)
        let stickerHeight = min(screenSpace/CGFloat(count), stickerMaxHeight)
        let stickerTop: CGFloat = closeButton.frame.top - itemsMargin - stickerHeight

        for i in 0..<count {
            buildSticker(stickers[i], top: stickerTop - (stickerHeight * CGFloat(i)), height: stickerHeight)
        }
    }

    private func buildSticker(sticker: Sticker, top: CGFloat, height: CGFloat) {
        guard let imageUrl = NSURL(string: sticker.url) else { return }

        let left = view.width - itemsMargin - height
        let stickerImage = UIImageView(frame: CGRect(x: left, y: top, width: height, height: height))
        view.addSubview(stickerImage)

        stickerImage.lg_setImageWithURL(imageUrl)
    }
}
