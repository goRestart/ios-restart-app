import AVFoundation
import Photos
import UIKit
import LGComponents

class MediaPickerManager {
    
    /**
    Show a generic image picker in the given UIViewController. The view controller must conform to
    UINavigationControllerDelegate and to UIImagePickerControllerDelegate.
    
    This method will first show a UIAlert asking to select the source of the media to pick, after that, this 
    class will handle all the stuff related with persmissions, restrictions and will notify the user, if necessary,
    presenting alerts in the given ViewController.
    
    - parameter controller: UIViewController where the ImagePicker is going to be shown.
    */
    static func showImagePickerIn<T: UIViewController>(_ controller: T) where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate {
           
            let title = R.Strings.sellPictureImageSourceTitle
            let cameraTitle = R.Strings.sellPictureImageSourceCameraButton
            let galleryTitle = R.Strings.sellPictureImageSourceCameraRollButton
            let cancelTitle = R.Strings.sellPictureImageSourceCancelButton
        
            let style: UIAlertControllerStyle = DeviceFamily.isiPad ? .alert : .actionSheet
        
            let alert = UIAlertController(title: title, message: nil, preferredStyle: style)
            alert.addAction(UIAlertAction(title: cameraTitle, style: .default) { alertAction in
                showCameraPickerIn(controller)
                })
            alert.addAction(UIAlertAction(title: galleryTitle, style: .default) { alertAction in
                showGalleryPickerIn(controller)
                })
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
            controller.presentViewController(alert, animated: true, onMainThread: true, completion: nil)
    }

    /**
    Show the native gallery image picker in the given UIViewController. The view controller must conform to
    UINavigationControllerDelegate and to UIImagePickerControllerDelegate.

    - parameter controller: UIViewController where the ImagePicker is going to be shown.
    */
    static func showGalleryPickerIn<T: UIViewController>(_ controller: T) where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate {
            self.requestGalleryPermissions(controller) {
                self.openImagePickerWithSource(.photoLibrary, inController: controller)
            }
    }

    /**
    Show the native camera in the given UIViewController to pick an image. The view controller must conform to
    UINavigationControllerDelegate and to UIImagePickerControllerDelegate.

    - parameter controller: UIViewController where the ImagePicker is going to be shown.
    */
    static func showCameraPickerIn<T: UIViewController>(_ controller: T) where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate {
            self.requestCameraPermissions(controller) {
                self.openImagePickerWithSource(.camera, inController: controller)
            }
    }

    static func hasCameraPermissions() -> Bool {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return false }
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return status == .authorized
    }

    static func requestCameraPermissions(_ controller: UIViewController, block: @escaping () -> ()) {
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                let message = R.Strings.productSellCameraRestrictedError
                showDefaultAlertWithMessage(message, inController: controller)
                return
            }
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch (status) {
            case .authorized:
                block()
            case .denied:
                let message = R.Strings.productSellCameraPermissionsError
                showSettingsAlertWithMessage(message, inController: controller)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            block()
                        }
                    }
                }
            case .restricted:
                // this will never be called, this status is not visible for the user
                // https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVCaptureDevice_Class/#//apple_ref/swift/enum/c:@E@AVAuthorizationStatus
                break
            }
    }


    // MARK: Private Methods
    
    private static func requestGalleryPermissions(_ controller: UIViewController, block: @escaping () -> ()) {
            
            let status = PHPhotoLibrary.authorizationStatus()
            switch (status) {
            case .authorized:
                block()
            case .denied:
                let message = R.Strings.productSellPhotolibraryPermissionsError
                showSettingsAlertWithMessage(message, inController: controller)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    if newStatus == .authorized {
                        DispatchQueue.main.async {
                            block()
                        }
                    }
                }
            case .restricted:
                let message = R.Strings.productSellPhotolibraryRestrictedError
                showDefaultAlertWithMessage(message, inController: controller)
                break
            }
    }

    private static func showDefaultAlertWithMessage(_ message: String, inController controller: UIViewController) {
            let alert = UIAlertController(title: R.Strings.commonErrorTitle, message: message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.Strings.commonOk, style: .default, handler: nil))
            controller.presentViewController(alert, animated: true, onMainThread: true, completion: nil)
    }
    
    private static func showSettingsAlertWithMessage(_ message: String, inController controller: UIViewController) {
            let alert = UIAlertController(title: R.Strings.commonErrorTitle, message: message,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.Strings.commonCancel, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: R.Strings.commonSettings, style: .default) { alertAction in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
                UIApplication.shared.openURL(settingsUrl)
            })
            controller.presentViewController(alert, animated: true, onMainThread: true, completion: nil)
    }
    
    private static func openImagePickerWithSource<T: UIViewController>(_ source: UIImagePickerControllerSourceType, inController controller: T) where T: UINavigationControllerDelegate,
        T: UIImagePickerControllerDelegate {
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.delegate = controller
            controller.presentViewController(picker, animated: true, onMainThread: true, completion: nil)
    }
}
