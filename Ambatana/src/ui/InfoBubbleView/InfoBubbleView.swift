//
//  LocationBubbleView.swift
//  LetGo
//
//  Created by Tomas Cobo on 26/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit

final class InfoBubbleView: UIView {
    
    static let bubbleHeight: CGFloat = 30
    
    //  MARK: - Subviews
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(size: 14)
        label.textAlignment = .center
        label.set(accessibilityId: .mainListingsInfoBubbleLabel)
        return label
    }()
    
    private let arrow: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "down_chevron_red"))
        imageView.contentMode = .center
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupSubviews()
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  MARK: - Private methods
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = InfoBubbleView.bubbleHeight/2
        applyShadow(withOpacity: 0.12, radius: 8.0)
    }
    
    private func setupSubviews() {
        addSubviewForAutoLayout(stackView)
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(arrow)
    }
    
    private func setupConstraints() {
        stackView.layout(with: self).fillVertical().fillHorizontal(by: 20)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: InfoBubbleView.bubbleHeight)
    }
    
}
