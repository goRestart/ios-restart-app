import Domain
import FirebaseAuth

struct RegisterUserFirebaseErrorAdapter {
  
  func make(_ error: Error) throws -> Error {
    let firebaseError = error as NSError
    let domainErrorCode = firebaseError.code
    
    switch domainErrorCode {
    case AuthErrorCode.weakPassword.rawValue:
      return RegisterUserError.invalidPassword
    case AuthErrorCode.invalidEmail.rawValue:
      return RegisterUserError.invalidEmail
    case AuthErrorCode.emailAlreadyInUse.rawValue:
      return RegisterUserError.emailIsAlreadyRegistered
    default:
      return error
    }
  }
}
