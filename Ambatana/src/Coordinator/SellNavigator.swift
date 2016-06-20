//
//  SellNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol SellNavigatorDelegate: class {
}

protocol SellNavigator: class {
    weak var delegate: SellNavigatorDelegate? { get }

    func open()
}
