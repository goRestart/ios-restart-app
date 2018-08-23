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
    var tags: [FilterTag] { get }
}

final class FilterTagFeedPresenter: BaseViewModel {
    
    let tags: [FilterTag]
    
    private weak var delegate: FilterTagsViewDelegate?
    
    init(delegate: FilterTagsViewDelegate,
         tags: [FilterTag]) {
        self.delegate = delegate
        self.tags = tags
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
