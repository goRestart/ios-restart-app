//
//  ListingCardView.swift
//  LetGo
//
//  Created by Facundo Menzella on 23/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

// TODO: ABIOS-3101 https://ambatana.atlassian.net/browse/ABIOS-3101
final class ListingCardView: UICollectionViewCell {

    private let listingIDLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    func populateWith(_ listingID: String) {
        listingIDLabel.text = listingID
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)

        contentView.addSubview(listingIDLabel)
        listingIDLabel.translatesAutoresizingMaskIntoConstraints = false

        listingIDLabel.layout(with: contentView).fillVertical().leadingMargin(by: 16).trailingMargin(by: -16)
        listingIDLabel.textAlignment = .center
        listingIDLabel.font = UIFont.bigBodyFont
    }

}
