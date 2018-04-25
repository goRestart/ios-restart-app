//
//  MockPreSignedUploadUrl+MockFactory.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 19/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockPreSignedUploadUrl: MockFactory {
    public static func makeMock() -> MockPreSignedUploadUrl {
        return MockPreSignedUploadUrl(form: MockPreSignedUploadUrlForm.makeMock(), expires: Date.makeRandom())
    }
}

extension MockPreSignedUploadUrlForm: MockFactory {
    public static func makeMock() -> MockPreSignedUploadUrlForm {
        var inputs: [String: String] = [:]
        let numOfInputs = Int.makeRandom(min: 1, max: 10)
        for _ in 0..<numOfInputs {
            inputs[String.makeRandom()] = String.makeRandom()
        }
        return MockPreSignedUploadUrlForm(inputs: inputs,
                                          action: URL.makeRandom())
    }
}
