import UIKit

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */

protocol Accessible {
    var identifier: String { get }
}

enum AccessibilityId: String, Accessible {
    
    var identifier: String { return rawValue }
    
    case helpWebView
}

extension UIAccessibilityIdentification {
    
    func set(accessibilityId: Accessible?) {
        accessibilityIdentifier = accessibilityId?.identifier
    }
}

extension NSObject {
    
    var accessibilityInspectionEnabled: Bool {
        get { return !accessibilityElementsHidden }
        set { accessibilityElementsHidden = !accessibilityInspectionEnabled }
    }
}
