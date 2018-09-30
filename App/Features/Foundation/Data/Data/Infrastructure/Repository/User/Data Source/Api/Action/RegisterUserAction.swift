import Domain
import Moya
import RxMoya
import RxSwift
import FirebaseAuth

struct RegisterUserAction {
  
  private let provider: MoyaProvider<UserService>
  private let errorAdapter: RegisterUserErrorAdapter
  
  init(provider: MoyaProvider<UserService>,
       errorAdapter: RegisterUserErrorAdapter)
  {
    self.provider = provider
    self.errorAdapter = errorAdapter
  }
  
  func execute(with credentials: UserCredentials) -> Completable {
    return provider.rx.request(.register(credentials))
      .map(AuthToken.self) { input, error in
        throw try self.errorAdapter.make(input, error)
      }.flatMapCompletable { auth in
        return Auth.auth().rx.signIn(with: auth.token)
    }
  }
}
