import Domain
import RxSwift
import Moya
import RxMoya
import FirebaseAuth

struct SignInUserAction {
  
  private let provider: MoyaProvider<AuthService>
  private let errorAdapter: SignInUserErrorAdapter
  private let authTokenStorage: AuthTokenStorage
  
  init(provider: MoyaProvider<AuthService>,
       errorAdapter: SignInUserErrorAdapter,
       authTokenStorage: AuthTokenStorage)
  {
    self.provider = provider
    self.errorAdapter = errorAdapter
    self.authTokenStorage = authTokenStorage
  }
  
  func authenticate(with credentials: BasicCredentials) -> Completable {
    return provider.rx.request(.signIn(credentials))
      .map(AuthToken.self) { input, error in
          throw try self.errorAdapter.make(error)
      }.flatMapCompletable { auth in
        try self.authTokenStorage.store(auth)
        return Auth.auth().rx.signIn(with: auth.token)
    }
  }
}
