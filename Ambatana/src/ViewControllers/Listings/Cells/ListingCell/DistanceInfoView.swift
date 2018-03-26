//
//  DistanceInfoView.swift
//  LetGo
//
//  Created by Haiyan Ma on 20/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class DistanceInfoView: UIView {
    
    private let distanceIcon: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.image = #imageLiteral(resourceName: "itemLocation")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .left
        label.font = ListingCellMetrics.DistanceView.distanceLabelFont
        label.applyShadow(withOpacity: 0.5, radius: 5, color: UIColor.black.cgColor)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setDistance(_ distance: String) {
        distanceLabel.text = distance
    }
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [distanceIcon, distanceLabel])
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 4.0
        
        addSubviewForAutoLayout(stackView)
        stackView.layout(with: self).fill()
        NSLayoutConstraint.activate([
            distanceIcon.heightAnchor.constraint(equalToConstant: ListingCellMetrics.DistanceView.iconHeight),
            distanceIcon.widthAnchor.constraint(equalToConstant: ListingCellMetrics.DistanceView.iconWidth)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

