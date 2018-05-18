//
//  RealEstateBannerPresenter.swift
//  LetGo
//
//  Created by Haiyan Ma on 24/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol RealEstateBannerPresenterDelegate: class {
    func openSell(source: PostingSource, postCategory: PostCategory?)
}

final class RealEstateBannerPresenter: FeedPresenter {
    
    private weak var delegate: RealEstateBannerPresenterDelegate?

    init(delegate: RealEstateBannerPresenterDelegate) {
        self.delegate = delegate
    }
    
    static var feedClass: AnyClass {
        return RealEstateHeaderCell.self
    }
    
    var height: CGFloat {
        return RealEstateHeaderCell.viewHeight
    }
}


// MARK: RealEstateBannerDelegate Implementation
extension RealEstateBannerPresenter: RealEstateBannerDelegate {
    
    func realEstateBannerPressed() {
        delegate?.openSell(source: .realEstatePromo, postCategory: .realEstate)
    }
}
