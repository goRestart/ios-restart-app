import Foundation

/*
 This is not the best way to validate emails but at least works
 */
public struct EmailValidator {
  public init() {}
  public func validate(_ input: String) -> Bool {
    let format = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let predicate = NSPredicate(format:"SELF MATCHES %@", format)
    return predicate.evaluate(with: input)
  }
}
