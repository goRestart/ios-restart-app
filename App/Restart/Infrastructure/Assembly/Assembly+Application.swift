import Core

extension Assembly {
  var application: Application {
    return Application(
      window: window,
      tabBar: tabBar
    )
  }
}
