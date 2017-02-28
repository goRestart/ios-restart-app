//
//  MockReceiptURLProvider.swift
//  LetGo
//
//  Created by Dídac on 27/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo

class MockReceiptURLProvider: ReceiptURLProvider {

    var appStoreReceiptURL: URL?

    init() {
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MockAppStoreReceiptURL")
        do {
            try "receipInfo".write(to: path, atomically: false, encoding: .utf8)
        }
        catch {
            print("⚠️ RECEIPT IS EMPTY! ⚠️")
        }
        self.appStoreReceiptURL = path
    }
}
