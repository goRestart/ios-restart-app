import Foundation
import UIKit

protocol CameraNavigatorDelegate: class {
  func didSelectImage(_ image: UIImage)
}

final class CameraNavigator: NSObject {
  
  private weak var from: UIViewController?
  weak var delegate: CameraNavigatorDelegate?
  
  init(from: UIViewController) {
    self.from = from
  }
  
  func navigate() {
    #if targetEnvironment(simulator)
    let simulatorImage = UIImage(named: "need_for_speed_most_wanted", in: .framework, compatibleWith: nil)!
    delegate?.didSelectImage(simulatorImage)
    #endif
  
    let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    if isCameraAvailable  {
      let imagePickerController = UIImagePickerController()
      imagePickerController.sourceType = .camera
      imagePickerController.cameraCaptureMode = .photo
      imagePickerController.delegate = self
      
      from?.present(imagePickerController, animated: true)
    }
  }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension CameraNavigator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let image = info[.originalImage] as? UIImage else { return }
    picker.dismiss(animated: true)
    delegate?.didSelectImage(image)
  }
}
