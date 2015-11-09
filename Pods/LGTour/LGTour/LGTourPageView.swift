//
//  LGTourPageView.swift
//  LGTour
//
//  Created by Albert Hernández López on 28/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import UIKit

/**
    Page in the tour.
*/
class LGTourPageView: UIView {
    
    // UI
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bodyLabel: UILabel!
    
    // MARK: - Lifecycle

    init(frame: CGRect, page: LGTourPage) {
        super.init(frame: frame)
        let view = NSBundle.LGTourBundle().loadNibNamed("LGTourPageView", owner: self, options: nil).first as! UIView
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        setupConstraints(view)
        setupUIWithPage(page)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let view = NSBundle.LGTourBundle().loadNibNamed("LGTourPageView", owner: self, options: nil).first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(view)
        
        setupConstraints(view)
    }
    
    // MARK: - Private methods
    
    /**
        Sets up the autolayout constraints.
    
        - parameter view: The parent view where to install the autolayout constraints.
    */
    private func setupConstraints(view: UIView) {
        let viewViews = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: viewViews))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: viewViews))
    }
    
    /**
        Sets up the user interface for a page data.
    
        - parameter tourPage: The page data.
    */
    private func setupUIWithPage(tourPage: LGTourPage) {
        switch tourPage.title {
        case .Text(let text):
            titleLabel.hidden = false
            titleLabel.text = text
            titleImageView.hidden = true
            titleImageViewWidthConstraint.constant = 0
            titleImageViewHeightConstraint.constant = 0
        case .Image(let image):
            titleLabel.hidden = true
            titleImageView.image = image
            titleImageView.hidden = false
            titleImageViewWidthConstraint.constant = image?.size.width ?? 0
            titleImageViewHeightConstraint.constant = image?.size.height ?? 0
        }
        bodyLabel.text = tourPage.body
    }
}
