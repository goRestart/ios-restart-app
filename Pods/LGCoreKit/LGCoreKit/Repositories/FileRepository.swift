//
//  FileRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 11/1/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result


public typealias FilesResult = Result<[File], RepositoryError>
public typealias FilesCompletion = FilesResult -> Void

public typealias FileResult = Result<File, RepositoryError>
public typealias FileCompletion =  FileResult -> Void


public protocol FileRepository {
    func upload(images: [UIImage], progress: ((Float) -> ())?, completion: FilesCompletion?)
    func upload(image: UIImage, progress: (Float -> ())?, completion: FileCompletion?)
}


public final class LGFileRepository: FileRepository {

    static let sharedInstance: LGFileRepository = LGFileRepository()
    
    let myUserRepository: MyUserRepository
    let fileDataSource: FileDataSource
    
    
    // MARK: - Inits
    
    convenience init() {
        let myUserRepo = MyUserRepository.sharedInstance
        let fileDataSource = FileApiDataSource.sharedInstance
        self.init(myUserRepository: myUserRepo, fileDataSource: fileDataSource)
    }
    
    init(myUserRepository: MyUserRepository, fileDataSource: FileDataSource) {
        self.myUserRepository = myUserRepository
        self.fileDataSource = fileDataSource
    }
    
    
    // MARK: - Upload
    
    public func upload(images: [UIImage], progress: ((Float) -> ())?, completion: FilesCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(FilesResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        guard images.count > 0 else {
            completion?(FilesResult(value: []))
            return
        }
        
        let datas = imagesData(images)
        let totalSteps = Float(images.count)
        uploadImages(userId, imageNameAndDatas: datas,
            step: { imagesUploadStep in
                progress?(Float(imagesUploadStep)/totalSteps)
            },
            completion: { result in
                completion?(result)
            }
        )
    }
    
    public func upload(image: UIImage, progress: (Float -> ())?, completion: FileCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(FileResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }
        
        guard let data = image.resizeImageData() else {
            completion?(FileResult(error: .Internal(message: "Failed to encode UIImage to NSData")))
            return
        }
        
        uploadFile(userId, data: data, imageName: "image.jpg", progress: progress, completion: completion)
    }
    
    
    
    // MARK: - Private
    
    private func uploadFile(userId: String, data: NSData, imageName: String, progress: (Float -> ())?,
        completion: FileCompletion?) {
            fileDataSource.uploadFile(userId, data: data, imageName: imageName, progress: progress) { result in
                if let value = result.value {
                    let file = LGFile(id: value, url: nil)
                    completion?(FileResult(value: file))
                } else if let error = result.error {
                    completion?(FileResult(error: RepositoryError(apiError: error)))
                }
            }
    }
    
    private func imagesData(images: [UIImage]) -> [(String, NSData)] {
        var imageNameAndDatas: [(String, NSData)] = []
        for (index, image) in images.enumerate() {
            if let data = image.resizeImageData() {
                let name = NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "",
                    options: [], range: nil) + "_\(index).jpg"
                let imageNameAndData = (name, data)
                imageNameAndDatas.append(imageNameAndData)
            }
        }
        return imageNameAndDatas
    }
    
    private func uploadImages(userId: String, imageNameAndDatas: [(String, NSData)], step: (Int) -> Void,
        completion: FilesCompletion?) {
            
            let fileUploadQueue = dispatch_queue_create("FileUploadQueue", DISPATCH_QUEUE_SERIAL)
            dispatch_async(fileUploadQueue, {
                
                var fileImages: [File] = []
                
                for imageNameAndData in imageNameAndDatas {
                    
                    let fileUploadResult = synchronize({ synchCompletion in
                        
                        self.uploadFile(userId, data: imageNameAndData.1, imageName: imageNameAndData.0, progress: nil,
                            completion: { result in
                                synchCompletion(result)
                        })
                        }, timeoutWith: FileResult(error: .Internal(message: "Timeout uploading image")))
                    
                    if let file = fileUploadResult.value {
                        fileImages.append(file)
                        dispatch_async(dispatch_get_main_queue()) {
                            step(fileImages.count)
                            if fileImages.count >= imageNameAndDatas.count {
                                completion?(FilesResult(value: fileImages))
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            let error = fileUploadResult.error ?? .Internal(message: "unknown error uploading file")
                            completion?(FilesResult(error: error))
                        }
                        break
                    }
                }
            })
    }
}
