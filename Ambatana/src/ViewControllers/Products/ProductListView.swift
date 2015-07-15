//
//  ProductListView.swift
//  LetGo
//
//  Created by AHL on 9/7/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

enum ProductListViewState {
    case FirstLoadView(String)  // loading label
    case DataView
    case ErrorView(UIImage?, String?, String?, String?, Void -> Void)  // image, title, body, button label, button action
}

class ProductListView: UIView, CHTCollectionViewDelegateWaterfallLayout, ProductListViewModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // UI
    // > First load
    @IBOutlet weak var firstLoadView: UIView!
    @IBOutlet weak var firstLoadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var firstLoadLabel: UILabel!
    
    // > Data
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // > Error
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var errorBodyLabel: UILabel!
    @IBOutlet weak var errorButton: UIButton!

    // Data
    var state: ProductListViewState {
        didSet {
            switch (state) {
            case .FirstLoadView(let loadingMessage):
                // UI
                firstLoadLabel.text = loadingMessage
                
                // Show/hide views
                firstLoadView.hidden = false
                dataView.hidden = true
                errorView.hidden = true
                
            case .DataView:
                // Show/hide views
                firstLoadView.hidden = true
                dataView.hidden = false
                errorView.hidden = true
                
            case .ErrorView(let errImage, let errTitle, let errBody, let errButAction):
                // UI
                // > Labels
                errorTitleLabel.text = errTitle
                errorBodyLabel.text = errBody
                
                // Show/hide views
                firstLoadView.hidden = true
                dataView.hidden = true
                errorView.hidden = false
            }
        }
    }
    
    // MARK: - Lifecycle
    
    public static func productListView() -> ProductListView {
        let productListView = NSBundle.mainBundle().loadNibNamed("ProductListView", owner: self, options: nil).first as! ProductListView
        productListView.setupUI()
        return productListView
    }
    
    func setupUI() {
        errorButton.addTarget(self, action: Selector("errorButtonPressed"), forControlEvents: .TouchUpInside)
    }
    
    @objc private func errorButtonPressed() {
        if state == .ErrorView(_, _, _, let errButAction) {
            errButAction()
        }
    }
    
}
