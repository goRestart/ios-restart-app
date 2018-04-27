//
//  PhotoViewerView.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

final class PhotoViewerView: UIView, PhotoViewerViewType, PhotoViewerBinderViewType {
    var rxTapControlEvents: Observable<UIControlEvents> { return tapControlEvents.asObservable().ignoreNil() }
    private let tapControlEvents: Variable<UIControlEvents?> = Variable<UIControlEvents?>(nil)

    var rxCollectionView: Reactive<UICollectionView> { return collectionView.rx }

    var currentPage: Int { return collectionLayout.currentPage }
    weak var dataSource: UICollectionViewDataSource? { didSet { collectionView.dataSource = dataSource } }
    weak var delegate: UICollectionViewDelegate? { didSet { collectionView.delegate = delegate } }

    private let collectionLayout = ListingDeckImagePreviewLayout()
    private let collectionView: UICollectionView
    private let pageControl = UIPageControl()
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
    
    func resumeVideoCurrentPage() {
        if let cell = collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0))
            as? ListingDeckVideoCell {
            cell.resume()
        }
    }

    @objc private func didTapCollectionView() {
        tapControlEvents.value = .touchUpInside
    }

    private func setupPageControl() {
        addSubviewForAutoLayout(pageControl)
        pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.bigMargin).isActive = true
        pageControl.layout(with: self).centerX()
    }

}
