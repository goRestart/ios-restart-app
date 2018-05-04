//
//  SearchAlertCreationParams+MockFactory.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 12/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension SearchAlertCreateParams: MockFactory {
    public static func makeMock() -> SearchAlertCreateParams {
        return SearchAlertCreateParams(objectId: String.makeRandom(),
                                       query: String.makeRandom(),
                                       latitude: Double.makeRandom(),
                                       longitude: Double.makeRandom(),
                                       createdAt: Date().roundedMillisecondsSince1970())
    }
}
