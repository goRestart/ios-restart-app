//
//  UIAction.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public enum UIActionInterface {
    case Text(String)
    case Image(UIImage?)
    case TextImage(String, UIImage)
}

public struct UIAction {
    let interface: UIActionInterface
    let action: () -> ()

    var text: String? {
        switch interface {
        case let .Text(text):
            return text
        case .Image:
            return nil
        case let .TextImage(text, _):
            return text
        }
    }
    var image: UIImage? {
        switch interface {
        case .Text:
            return nil
        case let .Image(image):
            return image
        case let .TextImage(_, image):
            return image
        }
    }
}
