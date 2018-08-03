public protocol NotificationGroupSetting: BaseModel {
    var name: String { get }
    var description: String? { get }
    var isEnabled: Bool { get }
    
    
    init(objectId: String?, name: String, description: String?, isEnabled: Bool)
}

extension NotificationGroupSetting {
    public func updating(isEnabled: Bool) -> NotificationGroupSetting {
        return type(of: self).init(objectId: objectId,
                                   name: name,
                                   description: description,
                                   isEnabled: isEnabled)
    }
}
