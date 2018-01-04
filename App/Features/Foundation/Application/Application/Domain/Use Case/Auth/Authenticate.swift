import Domain
import Core
import Data
import RxSwift

public struct Authenticate: AuthenticateUseCase {

  private let authRepository: AuthRepository

  init(authRepository: AuthRepository) {
    self.authRepository = authRepository
  }

  public func execute(with credentials: BasicCredentials) -> Completable {
    return authRepository.authenticate(with: credentials)
  }
}

// MARK: - Public initializer

extension Authenticate {
  public init() {
    self.authRepository = resolver.authRepository
  }
}
