import UIKit
import SignUp
import Core
import Data

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
    
    DataModule.start()
    
    let navigationController = UINavigationController(rootViewController: resolver.makeSignUp())
    window?.rootViewController = navigationController // tabBar.build()
    window?.makeKeyAndVisible()

    
    return true
  }
}
