//
//  RealEstateBanner.swift
//  LetGo
//
//  Created by Juan Iglesias on 09/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol RealEstateBannerDelegate: class {
    func realEstateBannerPressed()
}

class RealEstateBanner: UIView {
    
    private let backgroundImage = UIImageView()
    private let languageCode: String
    
    static let viewHeight: CGFloat = 200
    weak var delegate: RealEstateBannerDelegate?
    
    // MARK: - Lifecycle
    
    init(languageCode: String) {
        self.languageCode = languageCode
        super.init(frame: CGRect.zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupUI() {
        backgroundColor = .clear
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = languageCode == "es" ? #imageLiteral(resourceName: "real_estate_banner_es") : #imageLiteral(resourceName: "real_estate_banner_en")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(realEstateBannerPressed))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupLayout() {
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundImage)
        backgroundImage.layout(with: self).fill()
    }
    
    @objc private func realEstateBannerPressed() {
        delegate?.realEstateBannerPressed()
    }
}
