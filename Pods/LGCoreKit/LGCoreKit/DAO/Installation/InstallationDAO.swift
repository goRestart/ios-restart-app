//
//  InstallationDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import RxSwift

protocol InstallationDAO {

    /**
    Retrieves the current Installation object.
    If there is an Installation cached, will return that one.
    */
    var installation: Installation? { get }
    var rx_installation: Observable<Installation?> { get }

    /**
    Save an Installation instance.

    - parameter installation: Installation to save
    */
    func save(_ installation: Installation)

    /**
    Deletes the Installation instance.
    */
    func delete()
}
