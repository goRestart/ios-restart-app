//
//  UserPushPermissionsHeader.swift
//  LetGo
//
//  Created by Eli Kohen on 09/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol UserPushPermissionsHeaderDelegate: class {
    func pushPermissionHeaderPressed()
}

class UserPushPermissionsHeader: UIView {

    static let viewHeight: CGFloat = 50

    private static let iconWidth: CGFloat = 55
    private static let disclosureWidth: CGFloat = 27
    private static let messageMargin: CGFloat = 8

    weak var delegate: UserPushPermissionsHeaderDelegate?

    // MARK: - Lifecycle

    static func setupOnContainer(container: UIView) -> UserPushPermissionsHeader {
        let header = UserPushPermissionsHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(header)
        var views = [String: AnyObject]()
        views["header"] = header
        var metrics = [String: AnyObject]()
        metrics["height"] = UserPushPermissionsHeader.viewHeight
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|",
            options: [], metrics: nil, views: views))
        container.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header(height)]-0-|",
            options: [], metrics: metrics, views: views))
        return header
    }

    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 200, height: UserPushPermissionsHeader.viewHeight))
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
        icon.contentMode = .Center
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)

        let label = UILabel()
        label.font = UIFont.systemMediumFont(size: 17)
        label.textColor = UIColor.grayLighter
        label.text = LGLocalizedString.profilePermissionsHeaderMessage
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        let disclosure = UIImageView(image: UIImage(named: "ic_disclosure"))
        disclosure.contentMode = .Center
        disclosure.translatesAutoresizingMaskIntoConstraints = false
        addSubview(disclosure)

        var views = [String: AnyObject]()
        views["icon"] = icon
        views["label"] = label
        views["disclosure"] = disclosure

        var metrics = [String: AnyObject]()
        metrics["iconWidth"] = UserPushPermissionsHeader.iconWidth
        metrics["disclosureWidth"] = UserPushPermissionsHeader.disclosureWidth
        metrics["messageMargin"] = UserPushPermissionsHeader.messageMargin

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[icon(iconWidth)]-0-[label]-messageMargin-[disclosure(disclosureWidth)]-0-|",
            options: [.AlignAllCenterY], metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[icon]-0-|",
            options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[disclosure]-0-|",
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
