public protocol ServiceType {
    var id: String { get }
    var name: String { get }
    var subTypes: [ServiceSubtype] { get }
}
