//
//  InstallationDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

protocol InstallationDAO {

    /**
    Retrieves the current Installation object.
    If there is an Installation cached, will return that one.
    */
    var installation: Installation? { get }

    /**
    Save an Installation instance.

    - parameter installation: Installation to save
    */
    func save(installation: Installation)

    /**
    Deletes the Installation instance.
    */
    func delete()
}
