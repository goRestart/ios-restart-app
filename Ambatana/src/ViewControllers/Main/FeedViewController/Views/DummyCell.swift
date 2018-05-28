//
//  DummyCell.swift
//  LetGo
//
//  Created by Haiyan Ma on 20/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

struct EmptyFeedCellPresenter: FeedPresenter {
    
    static var feedClass: AnyClass {
        return DummyCell.self
    }

    var height: CGFloat {
        return DummyCell.viewHeight
    }
}


final class DummyCell: UICollectionViewCell, ReusableCell {
    
    static let viewHeight: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
