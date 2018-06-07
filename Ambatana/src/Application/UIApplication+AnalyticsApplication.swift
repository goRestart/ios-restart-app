//
//  UIApplication+AnalyticsApplication.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGComponents
import UIKit

extension UIApplication { // }: AnalyticsApplication {
    public func open(url: URL,
                     options: [String: Any],
                     completion: ((Bool) -> Void)?) {
        if #available(iOS 10, *) {
            open(url,
                 options: options,
                 completionHandler: completion)
        } else {
            let succeeded = openURL(url)
            completion?(succeeded)
        }
    }
}
