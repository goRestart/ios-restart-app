//
//  LGUserRetrieveService.swift
//  Pods
//
//  Created by Dídac on 21/09/15.
//
//

import Result
import Argo

final public class LGUserRetrieveService: UserRetrieveService {

    public func retrieveUserWithId(userId: String, completion: UserRetrieveServiceCompletion?) {
        let request = UserRouter.Show(userId: userId)
        ApiClient.request(request, decoder: LGUserRetrieveService.decoder) { (result: Result<User, ApiError>) -> () in
            if let value = result.value {
                completion?(UserRetrieveServiceResult(value: value))
            } else if let error = result.error {
                completion?(UserRetrieveServiceResult(error: UserRetrieveServiceError(apiError: error)))
            }
        }
    }

    static func decoder(object: AnyObject) -> User? {
        let theUser : LGUser? = decode(object)
        return theUser
    }
}
