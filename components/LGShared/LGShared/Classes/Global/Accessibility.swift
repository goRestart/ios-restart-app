import UIKit

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */

public protocol Accessible {
    var identifier: String { get }
}

public enum Accessibility: String, Accessible {
    
    public var identifier: String { return rawValue }
    
    case helpWebView
}

public extension UIAccessibilityIdentification {
    
    func set(accessibility: Accessible?) {
        accessibilityIdentifier = accessibility?.identifier
    }
}

public extension NSObject {
    
    var accessibilityInspectionEnabled: Bool {
        get { return !accessibilityElementsHidden }
        set { accessibilityElementsHidden = !accessibilityInspectionEnabled }
    }
}
