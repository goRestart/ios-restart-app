//
//  UserProfileTabsView.swift
//  LetGo
//
//  Created by Isaac Roldan on 22/2/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

protocol UserProfileTabsViewDelegate: class {
    func didSelect(tab: UserProfileTabType)
}

enum UserProfileTabType: Int {
    case selling = 0
    case sold
    case favorites
    case reviews

    var title: String {
        switch self {
        case .selling: return LGLocalizedString.profileSellingProductsTab
        case .sold: return LGLocalizedString.profileSoldProductsTab
        case .favorites: return LGLocalizedString.profileFavouritesProductsTab
        case .reviews: return LGLocalizedString.profileReviewsTab
        }
    }
}

struct UserProfileTabValue {
    let type: UserProfileTabType
}

final class UserProfileTabsView: UIView {
    private let stackView = UIStackView()
    fileprivate var tabs: [UserProfileTab] = []
    weak var delegate: UserProfileTabsViewDelegate?

    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        addSubviewForAutoLayout(stackView)
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
    }

    func setupConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupTabs(tabs: [UserProfileTabValue]) {
        for tab in tabs {
            let newTab = UserProfileTab(type: tab.type)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelect(sender:)))
            newTab.addGestureRecognizer(tapGesture)
            setupAccessibilityId(to: newTab, ofType: tab.type)
            stackView.addArrangedSubview(newTab)
            self.tabs.append(newTab)
        }
        self.tabs.first?.setSelected(selected: true)
    }

    private func setupAccessibilityId(to tab: UserProfileTab, ofType type: UserProfileTabType) {
        switch type {
        case .selling: tab.set(accessibilityId: .userSellingTab)
        case .sold: tab.set(accessibilityId: .userSoldTab)
        case .favorites: tab.set(accessibilityId: .userFavoritesTab)
        case .reviews: tab.set(accessibilityId: .userReviewsTab)
        }
    }

    @objc func didSelect(sender: UITapGestureRecognizer) {
        guard let senderTab = sender.view as? UserProfileTab else { return }
        for tab in tabs {
            tab.setSelected(selected: tab.type == senderTab.type)
        }
        delegate?.didSelect(tab: senderTab.type)
    }
}

private class UserProfileTab: UIView {
    var type: UserProfileTabType
    let nameLabel = UILabel()
    let selectedView = UIView()

    let selectedViewHeight: CGFloat = 3.0

    init(type: UserProfileTabType) {
        self.type = type
        nameLabel.text = type.title
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        addSubviewsForAutoLayout([nameLabel, selectedView])
        nameLabel.font = tabsFont(selected: false)
        nameLabel.textColor = .grayDark
        nameLabel.textAlignment = .center
        selectedView.alpha = 0
        selectedView.layer.cornerRadius = selectedViewHeight / 2
        selectedView.backgroundColor = .primaryColor
    }

    func setupConstraints() {
        let constraints = [
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.veryShortMargin),
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectedView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metrics.veryShortMargin),
            selectedView.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            selectedView.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
            selectedView.heightAnchor.constraint(equalToConstant: selectedViewHeight),
            selectedView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setSelected(selected: Bool) {
        nameLabel.font = tabsFont(selected: selected)
        nameLabel.textColor = selected ? .primaryColor : .grayDark
        UIView.animate(withDuration: 0.2) {
            self.selectedView.alpha = selected ? 1 : 0
        }
    }

    private func tabsFont(selected: Bool) -> UIFont {
        let isSmallPhone = .iPhone5 >= DeviceFamily.current
        if selected {
            return isSmallPhone ? .userProfileTabsNameSelectedMiniFont : .userProfileTabsNameSelectedFont
        } else {
            return isSmallPhone ? .userProfileTabsNameMiniFont : .userProfileTabsNameFont
        }
    }
}
