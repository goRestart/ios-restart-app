//
//  EditSellProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import SDWebImage
import LGCoreKit

protocol EditSellProductViewModelDelegate : class {
    func editSellProductViewModel(viewModel: EditSellProductViewModel, didDownloadImageAtIndex index: Int)
}

public class EditSellProductViewModel: SellProductViewModel {
 
    private var product: Product
    
//    weak var editDelegate: EditSellProductViewModelDelegate?
    
    public init(product: Product) {
        self.product = product
        super.init()
        
        if let name = product.name {
            self.title = name
        }
        if let currency = product.currency {
            self.currency = currency
        }
        if let price = product.price {
            self.price = price.stringValue
        }
        if let descr = product.descr {
            self.descr = descr
        }
        if let categoryId = product.categoryId?.integerValue {
            category = ProductCategory(rawValue: categoryId)
        }
        for i in 0..<product.images.count {
            images.append(nil)
        }

        // Download the images
        let imageDownloadQueue = dispatch_queue_create("EditSellProductViewModel", DISPATCH_QUEUE_SERIAL)
        dispatch_async(imageDownloadQueue, { () -> Void in
            for (index, image) in enumerate(product.images) {
                if let imageURL = image.fileURL, let data = NSData(contentsOfURL: imageURL) {
                    // Replace de image & notify the delegate
                    self.images[index] = UIImage(data: data)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.editDelegate?.editSellProductViewModel(self, didDownloadImageAtIndex: index)
                    })
                }
            }
        })
    }
    
    public override func save() {
        super.saveProduct(product: product)
    }
}
