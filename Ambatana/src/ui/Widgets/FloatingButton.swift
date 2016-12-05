//
//  FloatingButton.swift
//  LetGo
//
//  Created by Albert Hernández López on 17/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

public enum FloatingIconPosition {
    case Left
    case Right
}

class FloatingButton: UIView {
    private static let titleIconSpacing: CGFloat = 10
    private static let sideMargin: CGFloat = 25
    private static let iconSize: CGFloat = 28
    
    private let containerView: UIView
    private let icon: UIImageView
    private let iconPosition: FloatingIconPosition
    private let label: UILabel
    private let button: UIButton

    var buttonTouchBlock: (() -> ())?

    // MARK: - Lifecycle
    
    init(with title: String, image: UIImage?, position: FloatingIconPosition) {
        containerView = UIView()
        icon = UIImageView(frame: CGRectZero)
        icon.image = image
        iconPosition = position
        label = UILabel()
        label.text = title
        button = UIButton(type: .Custom)
        
        super.init(frame: CGRectZero)
        
        setupConstraints()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = height / 2
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: LGUIKitConstants.tabBarSellFloatingButtonHeight)
    }
    
    // MARK: - Setters

    func setIcon(with image: UIImage?) {
        icon.image = image
    }
    
    func setTitle(with string: String) {
        label.text = string
    }

    // MARK: - Private methods

    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(button)
        containerView.addSubview(icon)
        containerView.addSubview(label)
    
        let views = ["c": containerView, "b": button, "l": label, "i": icon]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[c]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[c]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[b]|", options: [], metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[b]|", options: [], metrics: nil, views: views))

        let leftView = iconPosition == .Left ? "i" : "l"
        let rightView = iconPosition == .Left ? "l" : "i"
        let metrics = ["spacing": FloatingButton.titleIconSpacing, "margin": FloatingButton.sideMargin]
        containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[\(leftView)]-spacing-[\(rightView)]-margin-|",
            options: [], metrics: metrics, views: views))
        
        containerView.addConstraint(NSLayoutConstraint(item: icon, attribute: .CenterY, relatedBy: .Equal,
            toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal,
            toItem: containerView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        
        containerView.addConstraint(NSLayoutConstraint(item: icon, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: FloatingButton.iconSize))
        containerView.addConstraint(NSLayoutConstraint(item: icon, attribute: .Height, relatedBy: .Equal,
            toItem: icon, attribute: .Width, multiplier: 1, constant: 0))
    }

    private func setupUI() {
        applyFloatingButtonShadow()
        containerView.clipsToBounds = true

        icon.contentMode = .ScaleAspectFit
        label.font = UIFont.veryBigButtonFont
        label.textColor = UIColor.white
        button.setStyle(.Primary(fontSize: .Big)) // just for backgrounds
        button.addTarget(self, action: #selector(didPressButton), forControlEvents: .TouchUpInside)
    }

    private dynamic func didPressButton() {
        buttonTouchBlock?()
    }
}
