import Foundation

/// Struct to help deserialise from the notification service extension
struct MutePushNotificationFeatureFlagHelper: Codable {
    let variable: Int
    let startHour: Int
    let endHour: Int    
}
