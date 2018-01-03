import Foundation

public struct UserCredentials {
  
  public let username: String
  public let email: String
  public let password: String
  
  public init(username: String,
              email: String,
              password: String)
  {
    self.username = username
    self.email = email
    self.password = password
  }
}
