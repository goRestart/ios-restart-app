//
//  ListingDeckVideoCell.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ListingDeckVideoCell: UICollectionViewCell, ReusableCell {

    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let blurred = UIImageView()
    private var disposeBag = DisposeBag()

    private let videoPreviewView: VideoPreview = {
        let preview = VideoPreview(frame: .zero)
        preview.contentMode = .scaleAspectFill
        preview.isUserInteractionEnabled = true
        preview.clipsToBounds = true
        return preview
    }()

    private let progressView: UIProgressView = {
        let bar = UIProgressView()
        bar.progressTintColor = .gray
        bar.trackTintColor = UIColor.black.withAlphaComponent(0.5)
        return bar
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRx()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: > Setup

    func setupUI() {
        clipsToBounds = true
        setupBlur()
        setupVideoPreview()
        setupProgressView()
    }

    private func setupProgressView() {
        contentView.addSubviewForAutoLayout(progressView)
        NSLayoutConstraint.activate([
            progressView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Metrics.margin),
            progressView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Metrics.margin),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.veryBigMargin)
        ])
    }

    private func setupRx() {
        videoPreviewView.rx_progress.asDriver().drive(onNext: { [weak self] progress in
            self?.updateVideoProgressWith(progress)
        }).disposed(by: disposeBag)
    }

    private func updateVideoProgressWith(_ progress: Float) {
        progressView.progress = progress
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
            self?.videoPreviewView.animateTo(alpha: 1)
        })
    }
    
    func resume() {
        videoPreviewView.play()
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
