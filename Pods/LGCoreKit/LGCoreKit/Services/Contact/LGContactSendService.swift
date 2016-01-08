//
//  LGContactSendService.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Result

final public class LGContactSendService: ContactSendService {

    public init() {}

    public func sendContact(contact: Contact, sessionToken: String?, completion: ContactSendServiceCompletion?) {

        var params = Dictionary<String, AnyObject>()

        params["email"] = contact.email
        params["title"] = contact.title
        params["description"] = contact.message

        let request = ContactRouter.Send(params: params)
        ApiClient.request(request, decoder: {$0}) { (result: Result<AnyObject, ApiError>) -> () in
            if let _ = result.value {
                completion?(ContactSendServiceResult(value: contact))
            } else if let error = result.error {
                completion?(ContactSendServiceResult(error: ContactSendServiceError(apiError: error)))
            }
        }
    }
}
