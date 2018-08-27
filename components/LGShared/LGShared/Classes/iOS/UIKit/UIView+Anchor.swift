import UIKit

extension UIView {
    public func constraintToEdges(in view: UIView) {
        NSLayoutConstraint.activate(
            constraintsToEdges(in: view)
        )
    }
    
    public func constraintsToEdges(in view: UIView) -> [NSLayoutConstraint] {
        let constraints = [
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.safeTopAnchor),
            bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        ]
        return constraints
    }
    
    public func constraintToCenter(in view: UIView) {
        let constraints = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Safe Area

extension UIView {
    public var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    public var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
}
