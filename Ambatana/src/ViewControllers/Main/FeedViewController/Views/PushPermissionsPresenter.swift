//
//  PushPermissionPresenter.swift
//  LetGo
//
//  Created by Stephen Walsh on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol PushPermissionsPresenterDelegate: class {
    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void), negativeAction: @escaping (() -> Void))
}

final class PushPermissionsPresenter: FeedPresenter {
    

    private weak var delegate: PushPermissionsPresenterDelegate?
    private let pushPermissionTracker: PushPermissionsTracker
    
    init(delegate: PushPermissionsPresenterDelegate,
         pushPermissionTracker: PushPermissionsTracker) {
        self.delegate = delegate
        self.pushPermissionTracker = pushPermissionTracker
    }
    
    static var feedClass: AnyClass {
        return PushPermissionsHeaderCell.self
    }
    
    var height: CGFloat {
        return PushPermissionsHeaderCell.viewHeight
    }
}


// MARK: PushPermissionsHeaderDelegate

extension PushPermissionsPresenter: PushPermissionsHeaderDelegate {
    
    func pushPermissionHeaderPressed() {
        pushPermissionTracker.trackPushPermissionStart()
        delegate?.showPushPermissionsAlert(withPositiveAction: { [weak self] in
            self?.pushPermissionTracker.trackPushPermissionComplete()
            }, negativeAction: { [weak self] in
                self?.pushPermissionTracker.trackPushPermissionCancel()
        })
    }
}
