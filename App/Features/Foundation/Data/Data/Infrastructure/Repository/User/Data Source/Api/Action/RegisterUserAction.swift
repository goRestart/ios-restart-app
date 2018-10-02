import Domain
import Moya
import RxMoya
import RxSwift
import FirebaseAuth

struct RegisterUserAction {
  
  private let provider: MoyaProvider<UserService>
  private let errorAdapter: RegisterUserErrorAdapter
  private let authTokenStorage: AuthTokenStorage
  
  init(provider: MoyaProvider<UserService>,
       errorAdapter: RegisterUserErrorAdapter,
       authTokenStorage: AuthTokenStorage)
  {
    self.provider = provider
    self.errorAdapter = errorAdapter
    self.authTokenStorage = authTokenStorage
  }
  
  func execute(with credentials: UserCredentials) -> Completable {
    return provider.rx.request(.register(credentials))
      .map(AuthToken.self) { input, error in
        throw try self.errorAdapter.make(input, error)
      }.flatMapCompletable { auth in
        try self.authTokenStorage.store(auth)
        return Auth.auth().rx.signIn(with: auth.token)
    }
  }
}
