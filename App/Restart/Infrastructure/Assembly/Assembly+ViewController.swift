import Core

enum MenuItem: Int {
  case listing
  case wishlist
  case publish
  case messages
  case profile
}

extension Assembly {
  var tabBarViewControllers: [UIViewController] {
    return [listing, wishlist, publish, messages, profile]
  }
}

// MARK: - Listing

extension Assembly {
  fileprivate var listing: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.listing"), tag: MenuItem.listing.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Wishlist

extension Assembly {
  fileprivate var wishlist: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.wishlist"), tag: MenuItem.wishlist.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Publish

extension Assembly {
  fileprivate var publish: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.upload"), tag: MenuItem.publish.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Messages

extension Assembly {
  fileprivate var messages: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.messages"), tag: MenuItem.messages.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}

// MARK: - Profile

extension Assembly {
  fileprivate var profile: UIViewController {
    let viewController = UIViewController()
    
    let tabBarItem = UITabBarItem(
      image: #imageLiteral(resourceName: "icon.tabbar.profile"), tag: MenuItem.profile.rawValue
    )
    viewController.tabBarItem = tabBarItem
    return viewController
  }
}
