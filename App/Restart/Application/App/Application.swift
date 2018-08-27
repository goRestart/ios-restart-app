import UIKit
import Core
import Data
import Listing

final class Application: NSObject, UIApplicationDelegate {
  
  var window: UIWindow?
  
  private let tabBarControllerProvider: TabBarControllerProvider
  
  init(window: UIWindow?,
       tabBarControllerProvider: TabBarControllerProvider)
  {
    self.window = window
    self.tabBarControllerProvider = tabBarControllerProvider
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    DataModule.start()
    
    window?.rootViewController = tabBarControllerProvider.makeTabBarController()
    window?.makeKeyAndVisible()

    return true
  }
}
