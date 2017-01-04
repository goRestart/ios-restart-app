//
//  UserPushPermissionsHeader.swift
//  LetGo
//
//  Created by Eli Kohen on 09/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol PushPermissionsHeaderDelegate: class {
    func pushPermissionHeaderPressed()
}

class PushPermissionsHeader: UIView {

    static let viewHeight: CGFloat = 50

    private static let iconWidth: CGFloat = 55
    private static let disclosureWidth: CGFloat = 27
    private static let messageMargin: CGFloat = 8

    weak var delegate: PushPermissionsHeaderDelegate?

    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 200, height: PushPermissionsHeader.viewHeight))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTap()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private methods

    private func setupUI() {
        backgroundColor = UIColor.black

        let icon = UIImageView(image: UIImage(named: "ic_messages"))
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)

        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 17)
        label.textColor = UIColor.grayLighter
        label.text = LGLocalizedString.profilePermissionsHeaderMessage
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        let disclosure = UIImageView(image: UIImage(named: "ic_disclosure"))
        disclosure.contentMode = .center
        disclosure.translatesAutoresizingMaskIntoConstraints = false
        addSubview(disclosure)

        var views = [String: AnyObject]()
        views["icon"] = icon
        views["label"] = label
        views["disclosure"] = disclosure

        var metrics = [String: AnyObject]()
        metrics["iconWidth"] = PushPermissionsHeader.iconWidth as AnyObject?
        metrics["disclosureWidth"] = PushPermissionsHeader.disclosureWidth as AnyObject?
        metrics["messageMargin"] = PushPermissionsHeader.messageMargin as AnyObject?

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[icon(iconWidth)]-0-[label]-messageMargin-[disclosure(disclosureWidth)]-0-|",
            options: [.alignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[icon]-0-|",
            options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[disclosure]-0-|",
            options: [], metrics: nil, views: views))
    }

    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tap)
    }

    private dynamic func viewTapped() {
        delegate?.pushPermissionHeaderPressed()
    }
}
