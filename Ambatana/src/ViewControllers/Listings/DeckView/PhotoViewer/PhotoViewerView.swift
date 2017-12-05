//
//  PhotoViewerView.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol PhotoViewerViewType: class {
    func updateCurrentPage(_ current: Int)
    func updateNumberOfPages(_ pagesCount: Int)
    func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String)
}

final class PhotoViewerView: UIView, PhotoViewerViewType, PhotoViewerBinderViewType {

    var rx_closeButton: Reactive<UIControl>? { return (closeButton as UIControl).rx }
    var rx_chatButton: Reactive<UIControl>? { return (chatButton as UIControl).rx }
    var rx_collectionView: Reactive<UICollectionView> { return collectionView.rx }

    weak var dataSource: UICollectionViewDataSource? {
        didSet { collectionView.dataSource = dataSource }
    }
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ListingDeckImagePreviewLayout())
    fileprivate let pageControl = UIPageControl()
    fileprivate let chatButton = ChatButton()
    fileprivate let closeButton = UIButton(type: .custom)

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func reloadData() {
        collectionView.reloadData()
    }

    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }

    func updateCurrentPage(_ current: Int) {
        pageControl.currentPage = current
    }

    func updateNumberOfPages(_ pagesCount: Int) {
        pageControl.numberOfPages = pagesCount
    }

    // MARK: Setup

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

        collectionView.backgroundColor = UIColor.grayLight
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
    }

    private func setupPageControl() {
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
