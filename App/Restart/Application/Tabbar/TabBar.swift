import UIKit
import UI

enum MenuItem: Int {
  case listing
  case wishlist
  case upload
  case messages
  case profile
}

final class TabBar {
  
  func build() -> UITabBarController {
    let tabBarController = TabBarController()
    tabBarController.viewControllers = [
      listing, wishlist, upload, messages, profile
    ]
    return tabBarController
  }
}

// MARK: - Listing

extension TabBar {
  var listing: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.listing"), tag: MenuItem.listing.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Wishlist

extension TabBar {
  var wishlist: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.wishlist"), tag: MenuItem.wishlist.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Upload

extension TabBar {
  var upload: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.upload"), tag: MenuItem.upload.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Messages

extension TabBar {
  var messages: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.messages"), tag: MenuItem.messages.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Profile

extension TabBar {
  var profile: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.profile"), tag: MenuItem.profile.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}
