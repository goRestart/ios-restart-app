//
//  PostProductCameraViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import RxSwift


protocol PostProductCameraViewModelDelegate: class {
    
}

enum CameraState {
    case Normal, MissingPermissions(String)
}

enum CameraFlashMode {
    case Auto, On, Off
}

enum CameraSourceMode {
    case Front, Rear
}

class PostProductCameraViewModel: BaseViewModel {

    weak var delegate: PostProductCameraViewModelDelegate?

    let cameraState = Variable<CameraState>(.Normal)
    let cameraFlashMode = Variable<CameraFlashMode>(.Auto)
    let cameraSourceMode = Variable<CameraSourceMode>(.Front)

    let infoShown = Variable<Bool>(false)
    let infoTitle = Variable<String>("")
    let infoSubtitle = Variable<String>("")
    let infoButton = Variable<String>("")

    private let disposeBag = DisposeBag()



    // MARK: - Public methods

    func infoButtonPressed() {
        switch cameraState.value {
        case .MissingPermissions:
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        case .Normal:
            break
        }
    }
}