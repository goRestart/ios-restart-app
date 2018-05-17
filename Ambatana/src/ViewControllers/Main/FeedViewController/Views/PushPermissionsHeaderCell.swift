//
//  PushPermissionHeaderCell.swift
//  LetGo
//
//  Created by Haiyan Ma on 23/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class PushPermissionsHeaderCell: UICollectionReusableView, ReusableCell {
    
    static let viewHeight: CGFloat = 50
    
    private let pushPermissionHeaderView = PushPermissionsHeader()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviewForAutoLayout(pushPermissionHeaderView)
        pushPermissionHeaderView.layout(with: self).fill()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with feedPresenter: PushPermissionsPresenter) {
        pushPermissionHeaderView.delegate = feedPresenter
    }
}
