import Foundation

public protocol Report: BaseModel {
    var objectId: String? { get }
    var reporterIdentity: String { get }
    var reportedIdentity: String { get }
    var reason: String { get }
    var status: String { get }
    var comment: String? { get }
    var score: Int? { get }
}
