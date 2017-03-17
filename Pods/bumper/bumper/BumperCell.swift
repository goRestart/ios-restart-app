//
//  BumperCell.swift
//  Pods
//
//  Created by Eli Kohen on 17/03/2017.
//
//

import UIKit

class BumperCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let infoLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupWith(title: String, value: String) {
        titleLabel.text = title
        infoLabel.text = value
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(infoLabel)

        var views = [String: Any]()
        views["titleLabel"] = titleLabel
        views["infoLabel"] = infoLabel

        infoLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        infoLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|",
                                                      options: [], metrics: nil, views: views))
        addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-[infoLabel]-|",
                                                      options: [], metrics: nil, views: views))

        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(rgb: 0x757575)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = UIColor(rgb: 0xff3f55)
        infoLabel.font = UIFont.boldSystemFont(ofSize: 15)
    }
}


extension UIColor {
    convenience init(rgb: UInt) {
        self.init(rgb: rgb, alpha: 1.0)
    }
    convenience init(rgb: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}
