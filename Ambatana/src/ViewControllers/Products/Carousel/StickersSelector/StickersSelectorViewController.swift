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
    private var stickersViews: [UIView] = []


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

        animateStickers()
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true) { [weak self] in
            self?.delegate?.stickersSelectorDidCancel()
        }
    }

    dynamic private func stickerPressed(sender: UITapGestureRecognizer?) {
        guard let index = sender?.view?.tag else { return }

        //TODO: ANIMATE SELECTION

        let sticker = stickers[index]
        dismissViewControllerAnimated(true) { [weak self] in
            self?.delegate?.stickersSelectorDidSelectSticker(sticker)
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

        for i in 0..<count {
            if let stView = buildSticker(stickers[i], top: closeButton.top, height: stickerMaxHeight, index: i) {
                stickersViews.append(stView)
            }
        }
    }

    private func buildSticker(sticker: Sticker, top: CGFloat, height: CGFloat, index: Int) -> UIView? {
        guard let imageUrl = NSURL(string: sticker.url) else { return nil }

        let stickerImage = UIImageView(frame: CGRect(x: 0, y: top, width: height, height: height))
        stickerImage.alpha = 0
        stickerImage.tag = index
        stickerImage.userInteractionEnabled = true
        view.addSubview(stickerImage)

        let tap = UITapGestureRecognizer(target: self, action: #selector(stickerPressed(_:)))
        stickerImage.addGestureRecognizer(tap)

        stickerImage.lg_setImageWithURL(imageUrl)

        return stickerImage
    }

    private func animateStickers() {
        let stickersViews = self.stickersViews
        let screenSpace = (closeButton.top - itemsMargin) - (titleLabel.bottom + itemsMargin)
        let stickerHeight = min(screenSpace/CGFloat(stickersViews.count), stickerMaxHeight)
        let left = view.width - itemsMargin - stickerHeight

        //Setting them in the correct origin
        for i in 0..<stickersViews.count {
            stickersViews[i].frame = CGRect(x: left, y: closeButton.top, width: stickerHeight, height: stickerHeight)
        }

        //Animate to final position
        let stickerTop: CGFloat = closeButton.top - itemsMargin - stickerHeight
        UIView.animateWithDuration(0.1, animations: {
            for i in 0..<stickersViews.count {
                var frame = stickersViews[i].frame
                frame.top = stickerTop - (stickerHeight * CGFloat(i))
                stickersViews[i].frame = frame
                stickersViews[i].alpha = 1
            }
        })
    }
}
