//
//  LGDateFormatter.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 23/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class LGDateFormatter: NSDateFormatter {

    
    // MARK: - Lifecycle

    public override init() {
        super.init()
        // ISO 8601
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        self.locale = enUSPosixLocale
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
