//
//  MockUserRepository.swift
//  LetGo
//
//  Created by Juan Iglesias on 13/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import Result
import LGCoreKit


class  MockUserRepository: UserRepository {
    
    func show(_ userId: String, completion: UserCompletion?) {}
    func retrieveUserToUserRelation(_ relatedUserId: String, completion: UserUserRelationCompletion?)  {}
    func indexBlocked(_ completion: UsersCompletion?)  {}
    func blockUserWithId(_ userId: String, completion: UserVoidCompletion?)  {}
    func unblockUserWithId(_ userId: String, completion: UserVoidCompletion?)  {}
    func unblockUsersWithIds(_ userIds: [String], completion: UserVoidCompletion?)  {}
    func saveReport(_ reportedUser: User, params: ReportUserParams, completion: UserCompletion?)  {}
    func saveReport(_ reportedUserId: String, params: ReportUserParams, completion: UserVoidCompletion?)  {}
    
}
