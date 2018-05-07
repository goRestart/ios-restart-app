//
//  MockMedia+MockFactory.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 23/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockMedia: MockFactory {
    public static func makeMock() -> MockMedia {
        return MockMedia(objectId: String.makeRandom(), type: MediaType.allValues.random()!,
                         snapshotId: String.makeRandom(), outputs: MockMediaOutputs.makeMock())
    }
    

}
