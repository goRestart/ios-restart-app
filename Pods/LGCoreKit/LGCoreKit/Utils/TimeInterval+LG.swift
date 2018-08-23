import Foundation

extension TimeInterval {
    
    func epochInSeconds() -> TimeInterval {
        guard self > 1_000_000_000_000 else { return self } // Checks epoch is in milliseconds, 13 digits
        return self/1000
    }
    
}
