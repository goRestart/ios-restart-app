//
//  ReportOptionCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 29/6/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

final class ReportOptionCell: UITableViewCell, ReusableCell {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.reportCellTitleFont
        label.textColor = UIColor.lgBlack
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
