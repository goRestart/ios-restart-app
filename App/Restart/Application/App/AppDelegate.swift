import UIKit
import Core

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  private let application = resolver.application
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    return self.application.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
