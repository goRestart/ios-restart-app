import Foundation

final class Fixture {
  /// Loads a JSON fixture from the test bundle
  ///
  /// - Parameter filePath: file path for the json file
  /// - Returns: json value (dictionary, array) depending on the T generic
  static func load<T>(_ filePath: String) -> T {
    let bundle = Bundle(for:object_getClass(self)!)
    let jsonFile = bundle.path(forResource: filePath, ofType: "json")
    let jsonData = NSData(contentsOfFile: jsonFile!)
    
    do {
      let json = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .allowFragments)
      return json as! T
    } catch {}
    
    return [:] as! T
  }
}

