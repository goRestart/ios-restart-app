import FBSDKCoreKit
import GoogleSignIn
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()
    lazy var coordinator: MainCoordinator = {
        return MainCoordinator()
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        printIntegrationInstructions()
        handle(application: application, didFinishLaunchingWithOptions: launchOptions)
        setupAppearance()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = coordinator.viewController
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        handleApplicationDidBecomeActive(application: application)
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return handle(application: app, openURL: url, options: options)
    }

    private func printIntegrationInstructions() {
        print("""
            ⚠️⚠️⚠️ READ CAREFULLY THIS INSTRUCTIONS ⚠️⚠️⚠️

            -------------------------------
            Facebook SDK & Google SDK Setup
            -------------------------------
            Please, double check:
                - Facebook: https://developers.facebook.com/docs/ios/getting-started/
                - Google: https://developers.google.com/identity/sign-in/ios/sign-in

            1. Configure Info.plist. Append before </dict> or update:
                <key>CFBundleURLTypes</key>
                <array>
                    <dict>
                        <key>CFBundleURLSchemes</key>
                        <array>
                            <string>fb699538486794082</string>
                        </array>
                        <key>CFBundleURLSchemes</key>
                        <array>
                            <string>com.googleusercontent.apps.914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp</string>
                        </array>
                    </dict>
                </array>
                <key>FacebookAppID</key>
                <string>699538486794082</string>
                <key>FacebookDisplayName</key>
                <string>letgo</string>
                <key>LSApplicationQueriesSchemes</key>
                <array>
                    <string>fbapi</string>
                    <string>fb-messenger-share-api</string>
                    <string>fbauth2</string>
                    <string>fbshareextension</string>
                </array>
            2. Copy handle(application:didFinishLaunchingWithOptions) func and its call from UIApplicationDelegate func
            3. Copy handleApplicationDidBecomeActive(application:) func and its call from UIApplicationDelegate func
            4. Copy handle(application:openURL:options:) func and its call from UIApplicationDelegate func
        """)
    }

    private func handle(application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        let googleSignIn = GIDSignIn.sharedInstance()
        googleSignIn?.clientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"
    }

    private func handleApplicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    private func handle(application: UIApplication,
                        openURL url: URL,
                        options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        let fbHandled = FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                              open: url,
                                                                              sourceApplication: sourceApplication,
                                                                              annotation: annotation)
        let googleHandled = GIDSignIn.sharedInstance().handle(url,
                                                              sourceApplication: sourceApplication,
                                                              annotation: annotation)
        let handled = fbHandled || googleHandled
        return handled
    }

    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor(rgb: 0xff3f55)
    }
}
