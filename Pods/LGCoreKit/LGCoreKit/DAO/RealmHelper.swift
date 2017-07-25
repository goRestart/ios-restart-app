//
//  RealmHelper.swift
//  LGCoreKit
//
//  Created by Dídac on 20/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import RealmSwift

class RealmHelper {
    static func convertArrayToRealmList<T: Object>(inputArray: [T]) -> List<T> {
        let resultList = List<T>()
        inputArray.forEach { item in
            resultList.append(item)
        }
        return resultList
    }

    static func convertRealmListToArray<T>(realmList: List<T>) -> [T] {
        return Array(realmList)
    }
}

extension Realm {
    func cancelWriteTransactionsIfNeeded() {
        if self.isInWriteTransaction {
            self.cancelWrite()
        }
    }
}
