//
//  RealEstateHeaderCell.swift
//  LetGo
//
//  Created by Stephen Walsh on 07/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class RealEstateHeaderCell: UICollectionReusableView, ReusableCell {
    
    static let viewHeight: CGFloat = 200
    
    private let realEstateBanner = RealEstateBanner()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewForAutoLayout(realEstateBanner)
        realEstateBanner.layout(with: self).fill()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with feedPresenter: RealEstateBannerPresenter) {
        realEstateBanner.delegate = feedPresenter
    }
}
