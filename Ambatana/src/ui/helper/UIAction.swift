//
//  UIAction.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum UIActionInterfaceStyle {
    case Default, Destructive, Cancel

    var alertActionStyle: UIAlertActionStyle {
        switch self {
        case .Default:
            return .Default
        case .Destructive:
            return .Destructive
        case .Cancel:
            return .Cancel
        }
    }

    var buttonStyle: ButtonStyle {
        switch self {
        case .Default:
            return .Primary(fontSize: .Medium)
        case .Cancel:
            return .Secondary(fontSize: .Medium, withBorder: true)
        case .Destructive:
            return .Terciary
        }
    }
}

enum UIActionInterface {
    case Text(String)
    case StyledText(String, UIActionInterfaceStyle)
    case Image(UIImage?)
    case TextImage(String, UIImage?)
    case Button(String, UIActionInterfaceStyle)
}

struct UIAction {
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
        case let .Button(text, _):
            return text
        }
        
    }
    var image: UIImage? {
        switch interface {
        case .Text, .StyledText, .Button:
            return nil
        case let .Image(image):
            return image
        case let .TextImage(_, image):
            return image
        }
    }
    var style: UIActionInterfaceStyle {
        switch interface {
        case .Text, .Image, .TextImage, .Button:
            return .Default
        case let .StyledText(_, style):
            return style
        }
    }

    var buttonStyle: ButtonStyle? {
        switch interface {
        case .Text, .Image, .TextImage, .StyledText:
            return nil
        case let .Button(_, style):
            return style.buttonStyle
        }
    }
}
