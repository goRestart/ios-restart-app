//
//  NSURL+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension NSURL {

    var queryParameters: [String : String] {
        var result : [String : String] = [:]
        guard let query = self.query else { return result }

        let mergedKeyValues = query.componentsSeparatedByString("&")
        for mergedKeyValue in mergedKeyValues {
            let keyValue = mergedKeyValue.componentsSeparatedByString("=")
            guard keyValue.count == 2 else { continue }
            guard let key = keyValue[0].stringByRemovingPercentEncoding,
                value = keyValue[1].stringByRemovingPercentEncoding else { continue }
            result[key] = value
        }
        return result
    }

    var components: [String] {
        guard var result = self.pathComponents else { return [] }
        if !result.isEmpty {
            result.removeAtIndex(0)
        }
        return result
    }
}
