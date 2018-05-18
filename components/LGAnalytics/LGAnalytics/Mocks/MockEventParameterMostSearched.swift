@testable import LGComponents
import LGCoreKit

extension EventParameterMostSearched: MockFactory {
    public static func makeMock() -> EventParameterMostSearched {
        return EventParameterMostSearched.allValues.random()!
    }
}

