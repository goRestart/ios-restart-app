import Domain
import Core
import Data
import RxSwift

public struct RegisterUser: RegisterUserUseCase {
  
  private let userRepository: UserRepository
  
  init(userRepository: UserRepository) {
    self.userRepository = userRepository
  }
  
  public func execute(with credentials: UserCredentials) -> Completable {
    return userRepository.register(with: credentials)
  }
}

// MARK: - Public initializer

extension RegisterUser {
  public init() {
    self.userRepository = resolver.userRepository
  }
}
