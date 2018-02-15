@testable import LetGoGodMode
import LGCoreKit

extension EventParameterMostSearched: MockFactory {
    public static func makeMock() -> EventParameterMostSearched {
        return EventParameterMostSearched.allValues.random()!
    }
}

