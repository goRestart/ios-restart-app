//
//  ReportProductNavigator.swift
//  LetGo
//
//  Created by Isaac Roldan on 3/7/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol ReportProductNavigator: class {
    func openNextStep(with options: ReportOptionsGroup)
    func openThankYouScreen()
}
