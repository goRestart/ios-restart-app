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
    let postButton: UIButton? = nil
    
    
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
    
    
    // MARK: - Overrides
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return [galleryButton, cameraButton, postButton].flatMap { $0 }.reduce(false) { (result, view) -> Bool in
            let convertedPoint = view.convert(point, from: self)
            return result || (!view.isHidden && view.point(inside: convertedPoint, with: event))
        }
    }
}


// MARK: - PostProductFooter

extension PostProductTabsFooter: PostProductFooter {   
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
        galleryButton?.accessibilityId = .postingGalleryButton
        cameraButton.accessibilityId = .postingPhotoButton
        postButton?.accessibilityId = .postingFooterPostButton
    }
    
    func setupLayout() {
        cameraButton.layout(with: self)
            .centerX()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -65)
        cameraButton.layout().width(80).widthProportionalToHeight()
    }
}
