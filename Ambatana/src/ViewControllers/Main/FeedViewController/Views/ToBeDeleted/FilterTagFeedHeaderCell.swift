//
//  FilterTagFeedHeaderCell.swift
//  LetGo
//
//  Created by Haiyan Ma on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class FilterTagFeedHeaderCell: UICollectionReusableView, ReusableCell {
    
    private let filterTagsView = FilterTagsView(frame: .zero)
    
    static let collectionViewHeight: CGFloat = 52
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubviewForAutoLayout(filterTagsView)
        filterTagsView.layout(with: self).fill()
    }
    
    func configure(with feedPresenter: FilterTagFeedPresentable) {
        filterTagsView.updateTags(feedPresenter.tags)
        filterTagsView.delegate = feedPresenter
    }
}

