//
//  FilterTagFeedPresenter.swift
//  LetGo
//
//  Created by Haiyan Ma on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import LGComponents

protocol FilterTagFeedPresentable: FilterTagsViewDelegate {
    var primaryTags: [FilterTag] { get }
    var secondaryTags: [FilterTag] { get }
}

final class FilterTagFeedPresenter: BaseViewModel {
    
    let primaryTags: [FilterTag]
    let secondaryTags: [FilterTag]
    
    private weak var delegate: FilterTagsViewDelegate?
    
    init(delegate: FilterTagsViewDelegate,
         primaryTags: [FilterTag],
         secondaryTags: [FilterTag]) {
        self.delegate = delegate
        self.primaryTags = primaryTags
        self.secondaryTags = secondaryTags
    }
}

extension FilterTagFeedPresenter: FeedPresenter {
    
    static var feedClass: AnyClass {
        return FilterTagFeedHeaderCell.self
    }
    
    var height: CGFloat {
        return FilterTagFeedHeaderCell.collectionViewHeight
    }
}


// MARK:- FilterTagFeedPresentable Implementation
extension FilterTagFeedPresenter: FilterTagFeedPresentable {
    
    func filterTagsViewDidRemoveTag(_ tag: FilterTag,
                                    remainingTags: [FilterTag]) {
        delegate?.filterTagsViewDidRemoveTag(tag,
                                             remainingTags: remainingTags)
    }
    
    func filterTagsViewDidSelectTag(_ tag: FilterTag) {
        delegate?.filterTagsViewDidSelectTag(tag)
    }

}
