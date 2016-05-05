//
//  AppRatingBannerView.swift
//  LetGo
//
//  Created by Eli Kohen on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol AppRatingBannerDelegate: class {
    func appRatingBannerClose()
    func appRatingBannerShowRating()
}

class AppRatingBannerView: UIView {

    //TODO: REMOVE WHEN USING APPRATINGMANAGER
    static var shouldShow: Bool {
        return true
    }

    static var height: CGFloat = 120

    weak var delegate: AppRatingBannerDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }


    // MARK: - Private methods

    // MARK: > UI

    private func setup() {

        //TODO: CHANGE BY PATTERN
        backgroundColor = StyleHelper.primaryColor
        setupMainAction()
        setupCloseButton()
    }

    private func setupMainAction() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mainActionPressed))
        addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupCloseButton() {
        let closeButton = UIButton(type: .Custom)
        closeButton.setImage(UIImage(named:"ic_close_dark"), forState: .Normal)
        addSubview(closeButton)
        let width = NSLayoutConstraint(item: closeButton, attribute: .Width, relatedBy: .Equal,
                                       toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        let height = NSLayoutConstraint(item: closeButton, attribute: .Width, relatedBy: .Equal,
                                       toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 40)
        closeButton.addConstraints([width, height])
        let top = NSLayoutConstraint(item: closeButton, attribute: .Top, relatedBy: .Equal,
                                     toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: closeButton, attribute: .Right, relatedBy: .Equal,
                                       toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        addConstraints([top,right])

        closeButton.addTarget(self, action: #selector(closeButtonPressed), forControlEvents: .TouchUpInside)
    }

    // MARK: > Actions

    dynamic private func mainActionPressed() {
        delegate?.appRatingBannerShowRating()
    }

    dynamic private func closeButtonPressed() {
        delegate?.appRatingBannerClose()
    }
}
