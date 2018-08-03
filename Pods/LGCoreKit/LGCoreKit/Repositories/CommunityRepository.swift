import Foundation

public protocol CommunityRepository {
    func buildCommunityURLRequest() -> URLRequest?
}
