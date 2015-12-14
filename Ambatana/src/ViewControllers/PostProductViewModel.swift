//
//  PostProductViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PostProductViewModelDelegate: class {
    func postProductViewModelDidStartUploadingImage(viewModel: PostProductViewModel)
    func postProductViewModelDidFinishUploadingImage(viewModel: PostProductViewModel, error: String?)
}

class PostProductViewModel: BaseViewModel {

    weak var delegate: PostProductViewModelDelegate?

    private var productManager: ProductManager
    private var uploadedImage: File?

    override init() {

        self.productManager = ProductManager()

        super.init()
    }


     // MARK: - Public methods

    func imageSelected(image: UIImage) {

        productManager.saveProductImages([image], progress: nil) {
            [weak self] (multipleFilesUploadResult: MultipleFilesUploadServiceResult) -> Void in

            guard let strongSelf = self else { return }
            guard let images = multipleFilesUploadResult.value, let image = images.first else {
                //TODO LOCALIZE ERROR
                strongSelf.delegate?.postProductViewModelDidFinishUploadingImage(strongSelf, error: "_")
                return
            }
            strongSelf.uploadedImage = image

            strongSelf.delegate?.postProductViewModelDidFinishUploadingImage(strongSelf, error: nil)
        }
    }
}
