//
//  PostProductPostFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostProductPostFooter: UIView {
    let galleryButton: UIButton? = UIButton()
    let cameraButton = UIButton()
    let postButton: UIButton? = UIButton()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateUI()
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

extension PostProductPostFooter: PostProductFooter {
    func update(scroll: CGFloat) {
        galleryButton?.alpha = scroll
        
        let rightOffset = cameraButton.frame.width/2 + Metrics.margin
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
        
        cameraButton.alpha = scroll
        postButton?.alpha = 1 - scroll
    }
}


// MARK: - Private methods

fileprivate extension PostProductPostFooter {
    func setupUI() {
        if let galleryButton = galleryButton {
            galleryButton.translatesAutoresizingMaskIntoConstraints = false
            galleryButton.setImage(#imageLiteral(resourceName: "ic_post_gallery"), for: .normal)
            addSubview(galleryButton)
        }
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setImage(#imageLiteral(resourceName: "ic_post_take_photo_icon"), for: .normal)
        cameraButton.setBackgroundImage(#imageLiteral(resourceName: "ic_post_take_photo"), for: .normal)
        addSubview(cameraButton)
        
        if let postButton = postButton {
            postButton.translatesAutoresizingMaskIntoConstraints = false
            postButton.setStyle(.primary(fontSize: .big))
            postButton.setTitle(LGLocalizedString.productPostUsePhoto, for: .normal)
            postButton.isHidden = true
            addSubview(postButton)
        }
    }
    
    func setupAccessibilityIds() {
        galleryButton?.accessibilityId = .postingGalleryButton
        cameraButton.accessibilityId = .postingPhotoButton
        postButton?.accessibilityId = .postingFooterPostButton
    }
    
    func setupLayout() {
        galleryButton?.layout(with: self)
            .leading()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        galleryButton?.layout().width(Metrics.sellGalleryIconSide).widthProportionalToHeight()
        
        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin)
        cameraButton.layout().width(Metrics.sellCameraIconMaxSide).widthProportionalToHeight()
        
        postButton?.layout().height(Metrics.buttonHeight)
        postButton?.layout(with: self)
            .trailing(by: -Metrics.margin)
            .bottom(by: -Metrics.margin)
    }
    
    func updateUI() {
        postButton?.rounded = true
    }
}
