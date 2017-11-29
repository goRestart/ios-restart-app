//
//  ListingCardDetailsView.swift
//  LetGo
//
//  Created by Facundo Menzella on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

final class ListingCardDetailsView: UIView {
    // do nothing, know nothing

    convenience init() {
        self.init(frame: .zero)
        setupUI()
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.layout(with: self).fill()

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)

        view.backgroundColor = .white
        view.heightAnchor.constraint(equalTo: heightAnchor, constant: 100).isActive = true
        view.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        view.layout(with: scrollView).fill()
    }
}
