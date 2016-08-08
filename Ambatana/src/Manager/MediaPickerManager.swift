//
//  MediaPickerManager.swift
//  LetGo
//
//  Created by Isaac Roldan on 1/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import AVFoundation
import Photos
import UIKit



class MediaPickerManager {
    
    /**
    Show a generic image picker in the given UIViewController. The view controller must conform to
    UINavigationControllerDelegate and to UIImagePickerControllerDelegate.
    
    This method will first show a UIAlert asking to select the source of the media to pick, after that, this 
    class will handle all the stuff related with persmissions, restrictions and will notify the user, if necessary,
    presenting alerts in the given ViewController.
    
    - parameter controller: UIViewController where the ImagePicker is going to be shown.
    */
    static func showImagePickerIn<T: UIViewController where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate>(controller: T) {
           
            let title = LGLocalizedString.sellPictureImageSourceTitle
            let cameraTitle = LGLocalizedString.sellPictureImageSourceCameraButton
            let galleryTitle = LGLocalizedString.sellPictureImageSourceCameraRollButton
            let cancelTitle = LGLocalizedString.sellPictureImageSourceCancelButton
        
            let style: UIAlertControllerStyle = DeviceFamily.isiPad ? .Alert : .ActionSheet
        
            let alert = UIAlertController(title: title, message: nil, preferredStyle: style)
            alert.addAction(UIAlertAction(title: cameraTitle, style: .Default) { alertAction in
                showCameraPickerIn(controller)
                })
            alert.addAction(UIAlertAction(title: galleryTitle, style: .Default) { alertAction in
                showGalleryPickerIn(controller)
                })
            alert.addAction(UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil))
            controller.presentViewController(alert, animated: true, onMainThread: true, completion: nil)
    }

    /**
    Show the native gallery image picker in the given UIViewController. The view controller must conform to
    UINavigationControllerDelegate and to UIImagePickerControllerDelegate.

    - parameter controller: UIViewController where the ImagePicker is going to be shown.
    */
    static func showGalleryPickerIn<T: UIViewController where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate>(controller: T) {
            self.requestGalleryPermissions(controller) {
                self.openImagePickerWithSource(.PhotoLibrary, inController: controller)
            }
    }

    /**
    Show the native camera in the given UIViewController to pick an image. The view controller must conform to
    UINavigationControllerDelegate and to UIImagePickerControllerDelegate.

    - parameter controller: UIViewController where the ImagePicker is going to be shown.
    */
    static func showCameraPickerIn<T: UIViewController where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate>(controller: T) {
            self.requestCameraPermissions(controller) {
                self.openImagePickerWithSource(.Camera, inController: controller)
            }
    }

    static func hasCameraPermissions() -> Bool {
        guard UIImagePickerController.isSourceTypeAvailable(.Camera) else { return false }
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        return status == .Authorized
    }

    static func requestCameraPermissions(controller: UIViewController, block: () -> ()) {
            guard UIImagePickerController.isSourceTypeAvailable(.Camera) else {
                let message = LGLocalizedString.productSellCameraRestrictedError
                showDefaultAlertWithMessage(message, inController: controller)
                return
            }
            let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
            switch (status) {
            case .Authorized:
                block()
            case .Denied:
                let message = LGLocalizedString.productSellCameraPermissionsError
                showSettingsAlertWithMessage(message, inController: controller)
            case .NotDetermined:
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    if granted {
                        dispatch_async(dispatch_get_main_queue()) {
                            block()
                        }
                    }
                }
            case .Restricted:
                // this will never be called, this status is not visible for the user
                // https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVCaptureDevice_Class/#//apple_ref/swift/enum/c:@E@AVAuthorizationStatus
                break
            }
    }


    // MARK: Private Methods
    
    private static func requestGalleryPermissions(controller: UIViewController, block: () -> ()) {
            
            let status = PHPhotoLibrary.authorizationStatus()
            switch (status) {
            case .Authorized:
                block()
            case .Denied:
                let message = LGLocalizedString.productSellPhotolibraryPermissionsError
                showSettingsAlertWithMessage(message, inController: controller)
            case .NotDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    if newStatus == .Authorized {
                        dispatch_async(dispatch_get_main_queue()) {
                            block()
                        }
                    }
                }
            case .Restricted:
                let message = LGLocalizedString.productSellPhotolibraryRestrictedError
                showDefaultAlertWithMessage(message, inController: controller)
                break
            }
    }

    private static func showDefaultAlertWithMessage(message: String, inController controller: UIViewController) {
            let alert = UIAlertController(title: LGLocalizedString.commonErrorTitle, message: message,
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: LGLocalizedString.commonOk, style: .Default, handler: nil))
            controller.presentViewController(alert, animated: true, onMainThread: true, completion: nil)
    }
    
    private static func showSettingsAlertWithMessage(message: String, inController controller: UIViewController) {
            let alert = UIAlertController(title: LGLocalizedString.commonErrorTitle, message: message,
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: LGLocalizedString.commonSettings, style: .Default) { alertAction in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })
            controller.presentViewController(alert, animated: true, onMainThread: true, completion: nil)
    }
    
    private static func openImagePickerWithSource<T: UIViewController where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate>(source: UIImagePickerControllerSourceType, inController controller: T) {
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.delegate = controller
            controller.presentViewController(picker, animated: true, onMainThread: true, completion: nil)
    }
}