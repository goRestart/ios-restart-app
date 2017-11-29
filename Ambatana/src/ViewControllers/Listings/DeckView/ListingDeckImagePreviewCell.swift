//
//  ListingDeckImagePreviewCell.swift
//  LetGo
//
//  Created by Facundo Menzella on 07/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

class ListingDeckImagePreviewCell: UICollectionViewCell {

    var position: Int = 0
    var imageURL: URL?
    var imageView = UIImageView()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: > Setup

    func setupUI() {
        clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layout(with: contentView).fill()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
    }
    
    
    // MARK: > Accessibility
    
    func setAccessibilityIds() {
        accessibilityId = .listingCarouselImageCell
        imageView.accessibilityId = .listingCarouselImageCellImageView
    }
}
