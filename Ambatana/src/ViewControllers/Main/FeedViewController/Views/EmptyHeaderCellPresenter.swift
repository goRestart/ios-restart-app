//
//  EmptyHeaderCell.swift
//  LetGo
//
//  Created by Haiyan Ma on 23/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

struct EmptyHeaderCellPresenter: FeedPresenter {
    
    static var feedClass: AnyClass {
        return EmptyHeaderReusableCell.self
    }

    var height: CGFloat {
        return EmptyHeaderReusableCell.viewHeight
    }
}

final class EmptyHeaderReusableCell: UICollectionReusableView, ReusableCell {
    
    static let viewHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
