//
//  UIViewConfigError.swift
//  LetGo
//
//  Created by Haiyan Ma on 25/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

enum UIViewConfigError: Error {
    case viewNotConfigured(view: UIView)
    var description: String {
        switch self {
        case .viewNotConfigured(let view):
            return "View: \(String(describing: view.self)) is not yet configured"
        }
    }
}
