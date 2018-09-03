import UIKit
import Core
import Data
import Listing
import SignUp

final class Application: NSObject, UIApplicationDelegate {
  
  var window: UIWindow?
  
  private let tabBarControllerProvider: TabBarControllerProvider
  
  init(window: UIWindow?,
       tabBarControllerProvider: TabBarControllerProvider)
  {
    self.window = window
    self.tabBarControllerProvider = tabBarControllerProvider
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    DataModule.start()
    
    window?.rootViewController = resolver.makeNotLogged() // tabBarControllerProvider.makeTabBarController()
    window?.makeKeyAndVisible()

    return true
  }
}
