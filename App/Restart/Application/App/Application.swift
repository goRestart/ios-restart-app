import Data
import Firebase

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

    window?.rootViewController =  tabBarControllerProvider.makeTabBarController()
    window?.makeKeyAndVisible()

    initializeModules()
    
    return true
  }
  
  private func initializeModules() {
    FirebaseApp.configure()
    
    let storage = Storage.storage()
    DataModule.shared.initialize(with: storage)
  }
}
