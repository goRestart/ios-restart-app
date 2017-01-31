//
//  BumpUpNavigator.swift
//  LetGo
//
//  Created by Dídac on 30/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol BumpUpNavigator: class {
    func bumpUpDidCancel()
    func bumpUpDidFinish(completion: (() -> Void)?)
}
