//
//  DummyUserDisclaimerView.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 29/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

class DummyUserDisclaimerView: UIView {
    
    static let viewHeight: CGFloat = 70

    private let corneredBackgroundView = UIView()
    private let infoImageView = UIImageView()
    private let textLabel = UILabel()
    
    private var infoText: String

    
    // MARK: - Lifecycle
    
    required init(infoText: String) {
        self.infoText = infoText
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = UIColor.grayBackground
        
        corneredBackgroundView.backgroundColor = UIColor.white
        corneredBackgroundView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        infoImageView.image = UIImage(named: "ic_info")
        
        textLabel.font = UIFont.systemRegularFont(size: 13)
        textLabel.textColor = UIColor.grayText
        textLabel.numberOfLines = 2
        textLabel.text = infoText
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.2
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        let subviews = [corneredBackgroundView, infoImageView, textLabel]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)
        addSubviews(subviews)
        
        corneredBackgroundView.layout(with: self).fill(by: Metrics.shortMargin)
        
        infoImageView.layout(with: self)
            .leading(by: Metrics.bigMargin)
            .centerY()
        infoImageView.layout()
            .height(24)
            .widthProportionalToHeight()
        
        textLabel.layout(with: infoImageView).toLeft(by: Metrics.shortMargin)
        textLabel.layout(with: self)
            .trailing(by: -50)
            .centerY()
        textLabel.layout().height(35)
    }
}
