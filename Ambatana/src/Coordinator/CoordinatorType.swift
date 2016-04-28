//
//  CoordinatorType.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol CoordinatorType {
    var children: [CoordinatorType] { get }
}
