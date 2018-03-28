//
//  ToastView.swift
//  LetGo
//
//  Created by Albert Hernández López on 13/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit

private extension UIColor {
    static let toastBackground = UIColor(red: 74, green: 74, blue: 74)
}

class ToastView: UIView {
    private struct Layout {
        static let insets = UIEdgeInsets(top: 8, left: 15, bottom: 9, right: 15)
    }
    static let standardHeight: CGFloat = 33

    let toastMessage: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemRegularFont(size: 13)
        return label
    }()

    var title: String = "" {
        didSet { toastMessage.text = title }
    }

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.toastBackground
        setupConstraints()
    }

    private func setupConstraints() {
        addSubviewForAutoLayout(toastMessage)
        NSLayoutConstraint.activate([
            toastMessage.topAnchor.constraint(equalTo: topAnchor, constant: Layout.insets.top),
            toastMessage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.insets.right),
            toastMessage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.insets.bottom),
            toastMessage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.insets.left)
        ])
    }
    
    override var intrinsicContentSize : CGSize {
        var size = toastMessage.intrinsicContentSize
        size.height += Layout.insets.top + Layout.insets.bottom
        size.width += Layout.insets.left + Layout.insets.right
        return size
    }
}
