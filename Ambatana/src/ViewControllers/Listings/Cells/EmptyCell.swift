//
//  EmptyCell.swift
//  LetGo
//
//  Created by Dídac on 10/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class EmptyCell: UICollectionViewCell, ReusableCell {

    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
