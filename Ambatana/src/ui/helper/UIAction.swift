//
//  UIAction.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

public enum UIActionInterfaceStyle {
    case Default, Destructive

    var alertActionStyle: UIAlertActionStyle {
        switch self {
        case .Default:
            return .Default
        case .Destructive:
            return .Destructive
        }
    }
}

public enum UIActionInterface {
    case Text(String)
    case StyledText(String, UIActionInterfaceStyle)
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
        case let .StyledText(text, _):
            return text
        case .Image:
            return nil
        case let .TextImage(text, _):
            return text
        }
        
    }
    var image: UIImage? {
        switch interface {
        case .Text, .StyledText:
            return nil
        case let .Image(image):
            return image
        case let .TextImage(_, image):
            return image
        }
    }
    var style: UIActionInterfaceStyle {
        switch interface {
        case .Text, .Image, .TextImage:
            return .Default
        case let .StyledText(_, style):
            return style
        }
    }
}
