import RxSwift
import Moya

extension PrimitiveSequence where Trait == RxSwift.SingleTrait, Element == Moya.Response {
  func map<D>(_ type: D.Type, _ f: @escaping (Any, Error) throws -> Error) -> Single<D> where D: Decodable {
    return self.map(type)
      .catchError { error in
        throw try self.extract(error, f)
    }
  }
  
  private func extract(_ error: Error, _ f: @escaping (Any, Error) throws -> Error) throws -> Error {
    guard let moyaError = error as? MoyaError,
      let json = try moyaError.response?.mapJSON() else {
        throw error
    }
    return try f(json, error)
  }
}
