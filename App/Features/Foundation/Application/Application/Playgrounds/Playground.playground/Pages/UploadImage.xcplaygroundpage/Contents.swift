import Application
import Domain
import PlaygroundSupport

/*:
 ## Upload image
 */

async { fulfill in
  
  let uploadImage = UploadImage()
  
  let url = URL.init(fileURLWithPath: "file path on disk")
  
  uploadImage.execute(with: url).subscribe(onSuccess: { image in
    print("Image = \(image)")
    fulfill()
  }, onError: { error in
    print("Error: \(error)")
    fulfill()
  })
}
//: [Previous](@previous)

