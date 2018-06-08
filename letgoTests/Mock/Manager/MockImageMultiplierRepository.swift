import LGCoreKit
import Result

final class MockImageMultiplierRepository: ImageMultiplierRepository {
    
    public var imagesIdsResults: [String]!
    
    func imageMultiplier(_ parameters: ImageMultiplierParams,
                         completion: ImageMultiplierCompletion?) {
        
        let deadline: DispatchTime = .now() + .milliseconds(50)
        let results = ImageMultiplierResult(value: imagesIdsResults)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion?(results)
        }
    }
}

extension MockImageMultiplierRepository: MockFactory {
    static func makeMock() -> MockImageMultiplierRepository {
        let repo = MockImageMultiplierRepository()
        repo.imagesIdsResults = [String.makeRandom()]
        return repo
    }
}
