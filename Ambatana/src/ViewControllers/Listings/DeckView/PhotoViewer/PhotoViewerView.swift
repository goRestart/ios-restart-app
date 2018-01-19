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

    var rxChatButton: Reactive<UIControl>? { return (chatButton as UIControl).rx }
    var rxCollectionView: Reactive<UICollectionView> { return collectionView.rx }

    weak var dataSource: UICollectionViewDataSource? {
        didSet { collectionView.dataSource = dataSource }
    }
    fileprivate let collectionLayout = ListingDeckImagePreviewLayout()
    fileprivate let collectionView: UICollectionView
    fileprivate let pageControl = UIPageControl()
    fileprivate let chatButton = ChatButton()
    fileprivate let closeButton = UIButton(type: .custom)

    convenience init() { self.init(frame: .zero) }

    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
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
        pageControl.alpha = pagesCount <= 1 ? 0 : 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionLayout.invalidateLayout()
    }

    // MARK: Setup

    private func setupUI() {
        setupCollectionView()
        setupChatbutton()
        setupPageControl()
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }

        addSubview(collectionView)
        collectionView.layout(with: self).fill()

        collectionView.backgroundColor = UIColor.grayLight
        collectionView.isPagingEnabled = true
        collectionView.delaysContentTouches = true
        collectionView.showsHorizontalScrollIndicator = false
    }

    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)

        pageControl.centerYAnchor.constraint(equalTo: chatButton.bottomAnchor,
                                             constant: -Metrics.shortMargin).isActive = true
        pageControl.layout(with: self).centerX()
    }

    private func setupChatbutton() {
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chatButton)

        chatButton.layout(with: self)
            .leadingMargin(by: Metrics.margin).bottomMargin(by: -Metrics.bigMargin)
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
            .size(withAttributes: [NSAttributedStringKey.font: textFont]).width
        return CGSize(width: width + 2*Metrics.margin + 44, height: 44) }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.white.cgColor

        let imageView = UIImageView(image: #imageLiteral(resourceName: "nit_photo_chat"))
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.isUserInteractionEnabled = false

        let label = UILabel()
        label.text = LGLocalizedString.photoViewerChatButton
        label.textColor = UIColor.white
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
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
