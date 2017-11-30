//
//  PhotoViewerView.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class PhotoViewerView: UIView {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ListingDeckImagePreviewLayout())
    let pageControl = UIPageControl()
    let chatButton = ChatButton()
    let closeButton = UIButton(type: .custom)

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        setupCollectionView()
        setupChatbutton()
        setupPageControl()
        setupCloseButton()
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.layout(with: self).fill()

        collectionView.backgroundColor = #colorLiteral(red: 0.7803921569, green: 0.8078431373, blue: 0.7803921569, alpha: 1)
    }

    private func setupPageControl() {
        // TODO: View not finished yet.
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)

        pageControl.numberOfPages = 4
        pageControl.currentPage = 1

        pageControl.centerYAnchor.constraint(equalTo: chatButton.bottomAnchor,
                                             constant: -Metrics.shortMargin).isActive = true
        pageControl.layout(with: self).centerX()
    }

    private func setupChatbutton() {
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatButton)

        chatButton.layout(with: self)
            .leadingMargin(by: Metrics.margin).bottomMargin(by: -Metrics.margin)
    }

    private func setupCloseButton() {
        closeButton.setImage(#imageLiteral(resourceName: "ic_close_carousel"), for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(closeButton)
        closeButton.layout().width(48).widthProportionalToHeight()
        closeButton.layout(with: self).topMargin(by: 2*Metrics.margin).leadingMargin()
    }
}

class ChatButton: UIControl {

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private let textFont = UIFont.systemBoldFont(size: 17)

    override var intrinsicContentSize: CGSize {

        let width = (LGLocalizedString.photoViewerChatButton as NSString)
            .size(attributes: [NSFontAttributeName: textFont]).width
        return CGSize(width: width + 2*Metrics.margin + 44, height: 44) }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor

        let imageView = UIImageView(image: #imageLiteral(resourceName: "nit_photo_chat"))
        imageView.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        imageView.isUserInteractionEnabled = false

        let label = UILabel()
        label.text = LGLocalizedString.photoViewerChatButton
        label.textColor = UIColor.white
        label.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        label.font = textFont
        label.isUserInteractionEnabled = false

        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: Metrics.margin, bottom: 0, right: Metrics.margin)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = false

        addSubview(stackView)

        stackView.axis = .horizontal
        stackView.spacing = Metrics.shortMargin
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.layout(with: self).fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(height, width) / 2.0
    }

}
