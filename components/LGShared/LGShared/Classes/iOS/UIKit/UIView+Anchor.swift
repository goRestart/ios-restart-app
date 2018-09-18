import UIKit

extension UIView {
  public func constraintToEdges(in view: UIView, insets: UIEdgeInsets = .zero) {
    NSLayoutConstraint.activate(
      constraintsToEdges(in: view, insets: insets)
    )
  }
  
  public func constraintsToEdges(in view: UIView, insets: UIEdgeInsets) -> [NSLayoutConstraint] {
    let constraints = [
      leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
      trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
      topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
      bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
    ]
    return constraints
  }
  
  public func constraintToCenter(in view: UIView) {
    let constraints = [
      centerXAnchor.constraint(equalTo: view.centerXAnchor),
      centerYAnchor.constraint(equalTo: view.centerYAnchor),
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

extension Array where Element: NSLayoutConstraint {
    public func activate() {
        NSLayoutConstraint.activate(self)
    }

    public func deactivate() {
        NSLayoutConstraint.deactivate(self)
    }
}
