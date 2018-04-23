//
//  LGPreSignedUploadUrl.swift
//  LGCoreKit
//
//  Created by Álvaro Murillo del Puerto on 12/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public enum PreSignedUploadUrlMethod: String, Decodable {
    case post = "POST"

    public static let allValues: [PreSignedUploadUrlMethod] = [.post]
}

public enum PreSignedUploadUrlEncodeType: String, Decodable {
    case multipart = "multipart/form-data"

    public static let allValues: [PreSignedUploadUrlEncodeType] = [.multipart]
}

public protocol PreSignedUploadUrl {
    var form: PreSignedUploadUrlForm { get }
    var expires: Date? { get }
}

public protocol PreSignedUploadUrlForm {
    var inputs: [String: String] { get }
    var action: URL { get }
    var method: PreSignedUploadUrlMethod { get }
    var encodeType: PreSignedUploadUrlEncodeType { get }
}

struct LGPreSignedUploadUrl: PreSignedUploadUrl, Decodable {

    public let form: PreSignedUploadUrlForm
    public let expires: Date?

    // MARK: Decodable

    /*
     {
     "form": { .... },
     "expires": "2018-04-12T15:44:37+00:00"
     }
     */

    public init(from decoder: Decoder) throws {
        let dateFormatter = LGDateFormatter()
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        form = try keyedContainer.decode(LGPreSignedUploadUrlForm.self, forKey: .form)
        let expiresString = try keyedContainer.decode(String.self, forKey: .expires)
        expires = dateFormatter.date(from: expiresString)
    }

    enum CodingKeys: String, CodingKey {
        case form = "form"
        case expires = "expires"
    }
}

struct LGPreSignedUploadUrlForm: PreSignedUploadUrlForm, Decodable {
    
    public let inputs: [String: String]
    public let action: URL
    public let method: PreSignedUploadUrlMethod
    public let encodeType: PreSignedUploadUrlEncodeType

    // MARK: Decodable

    /*
     {
     "inputs": {
        "key": "02/8b/ec/91/028bec91-9dd1-41f8-af70-8b87e0cfee35.mp4",
        "Content-Type": "video/mp4",
        "X-Amz-Security-Token": "FQoDYXdzE....",
        "X-Amz-Credential": "ASIAIWRJKMEJHGGC55JQ/20180412/us-east-1/s3/aws4_request",
        "X-Amz-Algorithm": "AWS4-HMAC-SHA256",
        "X-Amz-Date": "20180412T151437Z",
        "Policy": "eyJleHBpcmF0a....",
        "X-Amz-Signature": "9062d362..."
     },
     "action": "https://vid-in.stg.letgo.com",
     "method": "POST",
     "enc_type": "multipart/form-data"
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let actionURLString = try keyedContainer.decode(String.self, forKey: .action)
        if let actionURL = URL(string: actionURLString) {
            action = actionURL
        } else {
            let error = DecodingError.Context(codingPath: [CodingKeys.action], debugDescription: "\(actionURLString)")
            throw DecodingError.valueNotFound(PreSignedUploadUrlForm.self, error)
        }
        inputs = try keyedContainer.decode([String: String].self, forKey: .inputs)
        method = try keyedContainer.decode(PreSignedUploadUrlMethod.self, forKey: .method)
        encodeType = try keyedContainer.decode(PreSignedUploadUrlEncodeType.self, forKey: .encodeType)
    }

    enum CodingKeys: String, CodingKey {
        case inputs = "inputs"
        case action = "action"
        case method = "method"
        case encodeType = "enc_type"
    }
}
