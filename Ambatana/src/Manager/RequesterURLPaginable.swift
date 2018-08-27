import LGCoreKit
import Result

protocol RequesterURLPaginable {
    associatedtype ResultData: ResultProtocol
    
    typealias RequesterCompletion = ((ResultData) -> Void)
    
    func retrieve(_ completion: @escaping RequesterCompletion)
    func retrieve(nextURL url: URL, _ completion: @escaping RequesterCompletion)
}
