//
//  ReusableCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 30/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

protocol ReusableCell {
    static var reusableID: String { get }
}

extension ReusableCell {
    static var reusableID: String {
        return String(Self)
    }
}
