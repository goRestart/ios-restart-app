//
//  PostProductTabsFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostProductTabsFooter: UIView {
    let galleryButton: UIButton? = nil
    let cameraButton = UIButton()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - PostProductFooter

extension PostProductTabsFooter: PostProductFooter {
    func updateCameraButton(isHidden: Bool) {
        cameraButton.isHidden = isHidden
    }
    
    func update(scroll: CGFloat) {
        cameraButton.alpha = scroll
    }
}


// MARK: - Private methods

fileprivate extension PostProductTabsFooter {
    func setupUI() {
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setBackgroundImage(#imageLiteral(resourceName: "ic_post_take_photo_tabs"), for: .normal)
        cameraButton.setBackgroundImage(#imageLiteral(resourceName: "ic_post_take_photo_tabs_pressed"), for: .highlighted)
        addSubview(cameraButton)
    }
    
    func setupAccessibilityIds() {
        cameraButton.accessibilityId = .postingPhotoButton
    }
    
    func setupLayout() {
        cameraButton.layout(with: self)
            .centerX()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -65)
        cameraButton.layout().width(80).widthProportionalToHeight()
    }
}
