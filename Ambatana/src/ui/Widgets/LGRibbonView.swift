//
//  LGRibbonView.swift
//  LetGo
//
//  Created by Tomas Cobo on 11/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class LGRibbonView: UIView {
    
    var title: String = "" {
        didSet {
            stripeLabel.text = title
        }
    }
    
    //  MARK: - Subviews
    
    private let stripeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 12)
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .lgBlack
        label.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/4))
        return label
    }()
    
    private let stripeImageView = UIImageView(image: #imageLiteral(resourceName: "stripe_white"))
    
    init() {
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //  MARK: - Private methods
    
    private func setupSubviews() {
        clipsToBounds = true
        addSubviewsForAutoLayout([stripeImageView, stripeLabel])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stripeImageView.widthAnchor.constraint(equalToConstant: 70),
            stripeImageView.heightAnchor.constraint(equalToConstant: 70),
            stripeImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 2),
            stripeImageView.topAnchor.constraint(equalTo: topAnchor, constant: -2),
            
            stripeLabel.widthAnchor.constraint(equalToConstant: 63),
            stripeLabel.heightAnchor.constraint(equalToConstant: 24),
            stripeLabel.leadingAnchor.constraint(equalTo: stripeImageView.leadingAnchor, constant: 16),
            stripeLabel.centerYAnchor.constraint(equalTo: stripeImageView.centerYAnchor, constant: -7)
            ])
    }
    
}
