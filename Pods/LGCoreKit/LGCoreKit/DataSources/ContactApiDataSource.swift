//
//  ContactApiDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 25/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

class ContactApiDataSource: ContactDataSource {
    
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - ContactDataSource
    
    func send(email: String, title: String, message: String, completion: ContactDataSourceCompletion?) {
        let params = parameters(email, title: title, message: message)
        let request = ContactRouter.Send(params: params)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: - Private
    
    private func parameters(email: String, title: String, message: String) -> [String : AnyObject] {
        return ["email": email, "title": title, "description": message];
    }
}
