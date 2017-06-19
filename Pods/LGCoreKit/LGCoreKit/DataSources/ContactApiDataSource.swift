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
    
    func send(_ email: String, title: String, message: String, completion: ContactDataSourceCompletion?) {
        let params = parameters(email, title: title, message: message)
        let request = ContactRouter.send(params: params)
        apiClient.request(request, completion: completion)
    }
    
    
    // MARK: - Private
    
    private func parameters(_ email: String, title: String, message: String) -> [String : Any] {
        return ["email": email, "title": title, "description": message];
    }
}
