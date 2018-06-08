//
//  GradientView.swift
//  LetGo
//
//  Created by Facundo Menzella on 10/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import UIKit

final class GradientView: UIView {
    enum Direction {
        case horizontal, vertical
    }

    override var intrinsicContentSize: CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric) }

    private let gradient = CAGradientLayer()
    private let colors: [UIColor]
    private let locations: [Float]

    init(colors: [UIColor], locations: [Float] = [0 , 1]) {
        self.colors = colors
        self.locations = locations
        super.init(frame: .zero)
        self.isOpaque = false

        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayers() {
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations.map { NSNumber(value: $0) }

        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard gradient.frame != bounds else { return }
        gradient.frame = bounds
    }
}
