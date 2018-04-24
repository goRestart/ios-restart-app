//
//  ListingDeckVideoCell.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class ListingDeckVideoCell: UICollectionViewCell, ReusableCell {

    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let blurred = UIImageView()

    private let videoPreviewView: VideoPreview = {
        let preview = VideoPreview(frame: .zero)
        preview.contentMode = .scaleAspectFill
        preview.isUserInteractionEnabled = true
        preview.clipsToBounds = true
        return preview
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: > Setup

    func setupUI() {
        clipsToBounds = true
        setupBlur()
        setupVideoPreview()
    }

    func play(previewURL: URL?, videoURL: URL?) {
        if let previewURL = previewURL {
            do {
                if let image = try UIImage.imageFrom(url: previewURL) {
                    self.blurred.image = image
                }
                self.videoPreviewView.alpha = 0
            } catch _ {
                // do nothing, know nothing
                // FIXME: What do we do here?
            }
        }

        videoPreviewView.url = videoURL
        videoPreviewView.play()

        delay(0.5, completion: { [weak self] in
            self?.videoPreviewView.alphaAnimated(1)
        })
    }

    private func setupBlur() {
        contentView.addSubviewsForAutoLayout([blurred, effectView])
        blurred.layout(with: contentView).fill()
        effectView.layout(with: contentView).fill()
        blurred.contentMode = .scaleAspectFill
    }

    private func setupVideoPreview() {
        contentView.addSubviewForAutoLayout(videoPreviewView)
        videoPreviewView.layout(with: contentView).fill()
    }
}
