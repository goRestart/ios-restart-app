//
//  UserPushPermissionsHeader.swift
//  LetGo
//
//  Created by Eli Kohen on 09/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol UserPushPermissionsHeaderDelegate: class {
    func pushPermissionHeaderPressed()
}

class UserPushPermissionsHeader: UICollectionReusableView, ReusableCell {

    static let viewHeight: CGFloat = 50

    @IBOutlet weak var messageLabel: UILabel!

    weak var delegate: UserPushPermissionsHeaderDelegate?
    
    @IBAction func cellButtonPressed(sender: AnyObject) {
        delegate?.pushPermissionHeaderPressed()
    }
}
