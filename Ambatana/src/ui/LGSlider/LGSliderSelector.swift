//
//  LGSliderSelector.swift
//  LetGo
//
//  Created by Nestor on 04/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit


protocol LGSliderDataSource: class {
    func minimumConstraintConstant(sliderSelector: LGSliderSelector) -> CGFloat
    func maximumConstraintConstant(sliderSelector: LGSliderSelector) -> CGFloat
}


class LGSliderSelector {
    private var transformBackUp: CGAffineTransform = CGAffineTransform.identity
    let imageView: UIImageView
    var constraint = NSLayoutConstraint()
    var isDragging = false {
        didSet {
            if isDragging {
                imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05).concatenating(transformBackUp)
            } else {
                imageView.transform = transformBackUp
            }
        }
    }
    
    weak var dataSource: LGSliderDataSource?
    
    var minimumConstraintConstant: CGFloat {
        return dataSource?.minimumConstraintConstant(sliderSelector: self) ?? 0
    }
    
    var maximumConstraintConstant: CGFloat {
        return dataSource?.maximumConstraintConstant(sliderSelector: self) ?? 0
    }
    
    
    // MARK: - Lifecycle
    
    init(image: UIImage, rotate: Bool = false) {
        let shadowRadius: CGFloat = 1.5
        imageView = UIImageView(image: image)
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = false
        imageView.layer.shadowOffset = CGSize(width: 0, height: rotate ? -shadowRadius : shadowRadius)
        imageView.layer.shadowRadius = shadowRadius
        imageView.layer.shadowOpacity = 0.3
        imageView.transform = rotate ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
        transformBackUp = imageView.transform
    }
}
