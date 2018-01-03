import Core
import Moya

extension Assembly {
  func moyaProvider<T>() -> MoyaProvider<T> {
    return MoyaProvider()
  }
}
