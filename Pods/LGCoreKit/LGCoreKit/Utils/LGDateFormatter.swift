//
//  LGDateFormatter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 23/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

class LGDateFormatter: DateFormatter {

    
    // MARK: - Lifecycle

    override init() {
        super.init()
        // ISO 8601
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        self.locale = enUSPosixLocale
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
