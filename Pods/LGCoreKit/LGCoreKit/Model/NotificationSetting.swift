public protocol NotificationSetting: BaseModel {
    var name: String { get }
    var groupSettings: [NotificationGroupSetting] { get }
}
