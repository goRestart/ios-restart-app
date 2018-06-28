import Foundation

public extension URL {

    var queryParameters: [String : String] {
        var result : [String : String] = [:]
        guard let query = self.query else { return result }

        let mergedKeyValues = query.components(separatedBy: "&")
        for mergedKeyValue in mergedKeyValues {
            let keyValue = mergedKeyValue.components(separatedBy: "=")
            guard keyValue.count == 2 else { continue }
            guard let key = keyValue[0].removingPercentEncoding,
                let value = keyValue[1].removingPercentEncoding else { continue }
            result[key] = value
        }
        return result
    }

    var components: [String] {
        var result = pathComponents
        if !result.isEmpty {
            result.remove(at: 0)
        }
        return result
    }
}
