import Core

extension Assembly {
  var window: UIWindow? {
    return UIWindow(frame: screen.bounds)
  }
  
  private var screen: UIScreen {
    return .main
  }
}
