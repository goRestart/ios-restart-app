//
//  NSURL+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension URL {

    var queryParameters: [String : String] {
        var result : [String : String] = [:]
        guard let query = self.query else { return result }

        let mergedKeyValues = query.components(separatedBy: "&")
        for mergedKeyValue in mergedKeyValues {
            let keyValue = mergedKeyValue.components(separatedBy: "=")
            guard keyValue.count == 2 else { continue }
            guard let key = keyValue[0].stringByRemovingPercentEncoding,
                let value = keyValue[1].stringByRemovingPercentEncoding else { continue }
            result[key] = value
        }
        return result
    }

    var components: [String] {
        guard var result = self.pathComponents else { return [] }
        if !result.isEmpty {
            result.remove(at: 0)
        }
        return result
    }
}
