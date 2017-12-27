import Foundation
import PlaygroundSupport

/// Helper to run async code inside playground
///
/// - Parameter fulfill: after async code is executed you must call the fulfill closure in order to stop the async process ⚠️
public func async(_ fulfill: (@escaping () -> Void) -> Void) {
  PlaygroundPage.current.needsIndefiniteExecution = true
  
  fulfill() {
    PlaygroundPage.current.finishExecution()
  }
}
