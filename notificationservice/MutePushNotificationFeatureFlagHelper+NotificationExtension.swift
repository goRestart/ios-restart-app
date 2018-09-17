import Foundation

extension MutePushNotificationFeatureFlagHelper {
    
    var isABTestActive: Bool { return variable > 1 }
}
