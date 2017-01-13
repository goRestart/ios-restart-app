//
//  UIAction.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum UIActionInterfaceStyle {
    case standard, destructive, cancel

    var alertActionStyle: UIAlertActionStyle {
        switch self {
        case .standard:
            return .default
        case .destructive:
            return .destructive
        case .cancel:
            return .cancel
        }
    }

    var buttonStyle: ButtonStyle {
        switch self {
        case .standard:
            return .primary(fontSize: .medium)
        case .cancel:
            return .secondary(fontSize: .medium, withBorder: true)
        case .destructive:
            return .terciary
        }
    }
}

enum UIActionInterface {
    case text(String)
    case styledText(String, UIActionInterfaceStyle)
    case image(UIImage?, UIColor?) // Color will be the tint color if != nil
    case textImage(String, UIImage?)
    case button(String, ButtonStyle)
}

struct UIAction {
    let interface: UIActionInterface
    let action: () -> ()
    var accessibilityId: AccessibilityId?

    var text: String? {
        switch interface {
        case let .text(text):
            return text
        case let .styledText(text, _):
            return text
        case .image:
            return nil
        case let .textImage(text, _):
            return text
        case let .button(text, _):
            return text
        }
        
    }
    var image: UIImage? {
        switch interface {
        case .text, .styledText, .button:
            return nil
        case let .image(image, tint):
            if let _ = tint {
                return image?.withRenderingMode(.alwaysTemplate)
            } else {
                return image
            }
        case let .textImage(_, image):
            return image
        }
    }
    var imageTint: UIColor? {
        switch interface {
        case .text, .styledText, .button, .textImage:
            return nil
        case let .image(_, tint):
            return tint
        }
    }

    var style: UIActionInterfaceStyle {
        switch interface {
        case .text, .image, .textImage, .button:
            return .standard
        case let .styledText(_, style):
            return style
        }
    }

    var buttonStyle: ButtonStyle? {
        switch interface {
        case .text, .image, .textImage:
            return nil
        case let .styledText(_, interfaceStyle):
            return interfaceStyle.buttonStyle
        case let .button(_, style):
            return style
        }
    }

    init(interface: UIActionInterface, action: @escaping () -> (), accessibilityId: AccessibilityId? = nil) {
        self.interface = interface
        self.action = action
        self.accessibilityId = accessibilityId
    }
}
