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
    var rxTapControlEvents: Observable<UIControlEvents> { return tapControlEvents.asObservable().ignoreNil() }
    private let tapControlEvents: Variable<UIControlEvents?> = Variable<UIControlEvents?>(nil)

    var rxChatButton: Reactive<UIControl>? { return (chatButton as UIControl).rx }
    var rxCollectionView: Reactive<UICollectionView> { return collectionView.rx }

    var currentPage: Int { return collectionLayout.currentPage }
    weak var dataSource: UICollectionViewDataSource? { didSet { collectionView.dataSource = dataSource } }
    weak var delegate: UICollectionViewDelegate? { didSet { collectionView.delegate = delegate } }

    private let collectionLayout = ListingDeckImagePreviewLayout()
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()
    private let chatButton = ChatButton()
    private let closeButton = UIButton(type: .custom)

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
        collectionView.bounces = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCollectionView))
        collectionView.addGestureRecognizer(tap)
    }

    func previewCellAt(_ index: Int) -> ListingDeckImagePreviewCell? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ListingDeckImagePreviewCell
    }

    @objc private func didTapCollectionView() {
        tapControlEvents.value = .touchUpInside
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
        applyShadowToLayer(layer)

        let imageView = UIImageView(image: #imageLiteral(resourceName: "nit_photo_chat"))
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.isUserInteractionEnabled = false
        applyShadowToLayer(imageView.layer)

        let label = UILabel()
        label.text = LGLocalizedString.photoViewerChatButton
        label.textColor = UIColor.white
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.font = textFont
        label.isUserInteractionEnabled = false
        applyShadowToLayer(label.layer)

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

    private func applyShadowToLayer(_ layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setRoundedCorners()
        let cornerRadius = min(height, width) / 2.0
        layer.shadowRadius = cornerRadius
    }
}
