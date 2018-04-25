//
//  MockVideo+MockFactory.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 25/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockVideo: MockFactory {
    public static func makeMock() -> MockVideo {
        return MockVideo(path: String.makeRandom(length: 10), snapshot: String.makeRandom(length: 10))
    }
}
