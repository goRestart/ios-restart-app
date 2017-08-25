//
//  PostListingRedCamButtonFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostListingRedCamButtonFooter: UIView {
    static let galleryIconSide: CGFloat = 70
    static let cameraIconSide: CGFloat = 84
    
    let galleryButton = UIButton()
    let cameraButton = UIButton()
    fileprivate var cameraButtonCenterXConstraint: NSLayoutConstraint?
    
    
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
        return [galleryButton, cameraButton].flatMap { $0 }.reduce(false) { (result, view) -> Bool in
            let convertedPoint = view.convert(point, from: self)
            return result || (!view.isHidden && view.point(inside: convertedPoint, with: event))
        }
    }
}


// MARK: - PostListingFooter

extension PostListingRedCamButtonFooter: PostListingFooter {
    func update(scroll: CGFloat) {
        galleryButton.alpha = scroll
        
        let rightOffset = cameraButton.frame.width/2 + Metrics.margin
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
    }   
}


// MARK: - Private methods

fileprivate extension PostListingRedCamButtonFooter {
    func setupUI() {
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.setImage(#imageLiteral(resourceName: "ic_post_gallery"), for: .normal)
        addSubview(galleryButton)
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setImage(#imageLiteral(resourceName: "ic_post_take_photo_icon"), for: .normal)
        cameraButton.setBackgroundImage(#imageLiteral(resourceName: "ic_post_take_photo"), for: .normal)
        addSubview(cameraButton)
    }
    
    func setupAccessibilityIds() {
        galleryButton.accessibilityId = .postingGalleryButton
        cameraButton.accessibilityId = .postingPhotoButton
    }
    
    func setupLayout() {
        galleryButton.layout(with: self)
            .leading()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        galleryButton.layout()
            .width(PostListingRedCamButtonFooter.galleryIconSide)
            .widthProportionalToHeight()
        
        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin)
        cameraButton.layout().width(PostListingRedCamButtonFooter.cameraIconSide).widthProportionalToHeight()
    }
}
