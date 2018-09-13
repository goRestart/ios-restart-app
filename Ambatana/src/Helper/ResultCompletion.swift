import Foundation
import Result

typealias ResultCompletion<T, Error: Swift.Error> = (Result<T, Error>) -> Void
