@testable import LetGoGodMode
import LGCoreKit

extension EventParameterPostingAbandonStep: MockFactory {
    public static func makeMock() -> EventParameterPostingAbandonStep {
        return EventParameterPostingAbandonStep.allValues.random()!
    }
}

