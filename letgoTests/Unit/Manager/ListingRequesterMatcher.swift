@testable import LetGoGodMode
import Quick
import Nimble

/// Custom Nimble Matcher to compare if two arrays of ListingListRequester are identical
///
/// - Parameter expectedRequesters: array of ListingListRequester
/// - Returns: PredicateResult
func equal(expectedRequesters: [ListingListRequester]) -> Predicate<[ListingListRequester]> {
    return Predicate { expression in
        
        guard let array = try expression.evaluate() else {
            return PredicateResult(status: .fail,
                                   message: .fail("failed evaluating expression"))
        }
        
        guard expectedRequesters.count == array.count else {
            return PredicateResult(status: .fail,
                                   message: .expectedCustomValueTo("requester array count is \(expectedRequesters.count)", "\(array.count)"))
        }
        
        let unmatchingRequesterIndex = zip(expectedRequesters, array)
            .map { return $0.isEqual(toRequester: $1) }
            .index(of: false)
        
        
        if let unmatchingIndex = unmatchingRequesterIndex {
            return PredicateResult(status: .fail,
                                   message: .fail("requester at \(unmatchingIndex) doesn't match "))
        }
        
        return PredicateResult(status: .matches,
                               message: .expectedTo("expectation fulfilled"))
    }
}

