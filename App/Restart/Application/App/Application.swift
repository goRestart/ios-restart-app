import UIKit

final class Application: NSObject, UIApplicationDelegate {
  
  var window: UIWindow?
  private let tabBar: TabBar
  
  init(window: UIWindow?,
       tabBar: TabBar)
  {
    self.window = window
    self.tabBar = tabBar
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    window?.rootViewController = tabBar.build()
    window?.makeKeyAndVisible()
    
    return true
  }
}
