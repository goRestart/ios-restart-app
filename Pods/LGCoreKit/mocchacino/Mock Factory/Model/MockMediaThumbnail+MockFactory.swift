//
//  MockMediaThumbnail+MockFactory.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 23/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockMediaThumbnail: MockFactory {
    public static func makeMock() -> MockMediaThumbnail {
        return MockMediaThumbnail(file: MockFile.makeMock(), type: MediaType.allValues.random()!, size: LGSize.makeMock())
    }
}
