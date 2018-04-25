//
//  MockMediaOutputs+MockFactory.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 23/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockMediaOutputs: MockFactory {
    public static func makeMock() -> MockMediaOutputs {
        return MockMediaOutputs(image: URL.makeRandom(), imageThumbnail: URL.makeRandom(),
                                video: URL.makeRandom(), videoThumbnail: URL.makeRandom())
    }
    
    
}
