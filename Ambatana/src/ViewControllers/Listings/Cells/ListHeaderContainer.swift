//
//  ListHeaderContainer.swift
//  LetGo
//
//  Created by Eli Kohen on 24/10/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ListHeaderContainer: UICollectionReusableView, ReusableCell {

    var totalHeight: CGFloat = 0

    enum HeaderStyle {
        case fullWidth
        case bubble
    }

    func getHeader(_ tag: Int) -> UIView? {
        for view in subviews {
            if view.tag == tag {
                return view
            }
        }
        return nil
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .clear
    }

    func addHeader(_ view: UIView, height: CGFloat, style: HeaderStyle = .fullWidth) {
        guard getHeader(view.tag) == nil else { return }
        addSubviewForAutoLayout(view)

        switch style {
        case .fullWidth:
            view.layout(with: self).fillHorizontal().top(by: totalHeight)
        case .bubble:
            view.layout(with: self).fillHorizontal(by: 10).top(by: totalHeight)
            view.layer.cornerRadius = 10
        }
        view.layout().height(height)
        totalHeight += height
    }

    func clear() {
        subviews.forEach { $0.removeFromSuperview() }
        totalHeight = 0
    }
}
