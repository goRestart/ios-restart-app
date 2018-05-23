//
//  ListingDeckImagePreviewCell.swift
//  LetGo
//
//  Created by Facundo Menzella on 07/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

final class ListingDeckImagePreviewCell: UICollectionViewCell, ReusableCell {

    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let blurred = UIImageView()

    private let zoomableImageView = ZoomableImageView()

    var isZooming: Bool { return zoomableImageView.isZooming }

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: > Setup

    override func prepareForReuse() {
        super.prepareForReuse()
        zoomableImageView.setImage(nil)
        blurred.image = nil
    }

    func setupUI() {
        clipsToBounds = true
        setupBlur()
        setupZoomablePreview()
    }

    private func setupBlur() {
        contentView.addSubviewsForAutoLayout([blurred, effectView])
        blurred.layout(with: contentView).fill()
        effectView.layout(with: contentView).fill()
        blurred.contentMode = .scaleAspectFill
    }

    private func setupZoomablePreview() {
        contentView.addSubviewForAutoLayout(zoomableImageView)
        zoomableImageView.layout(with: contentView).fill()
        zoomableImageView.contentMode = .scaleAspectFill
        zoomableImageView.isUserInteractionEnabled = true
    }

    func resetZoom(animated: Bool = false) {
        zoomableImageView.resetZoom()
    }

    func setImage(_ image: UIImage) {
        blurred.image = image
        zoomableImageView.setImage(image)
    }
}
