import Application
import Domain
import PlaygroundSupport

/*:
 ## Authenticate user (Login)
 
 This use case is usted to authenticate an user with **Restart** backend. It uses `BasicCredentials` to authenticate with the server.
 */

// ⚠️ Update with your credentials
let credentials = BasicCredentials(
  username: "username",
  password: "password"
)

async { fulfill in
  
  let authenticate = Authenticate()
  authenticate.execute(with: credentials).subscribe(onCompleted: {
    print("Logged in as `\(credentials.username)` 🖖🏽")
    fulfill()
  }) { error in
    switch error as? AuthError {
    case .invalidCredentials?:
      print("🚨 Invalid credentials = \(credentials)")
    default:
      print("Unknown error")
    }
    fulfill()
  }
}
//: [Previous](@previous)
