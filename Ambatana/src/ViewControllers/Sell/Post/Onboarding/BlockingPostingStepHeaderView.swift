//
//  BlockingPostingStepHeaderView.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 06/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGComponents

protocol BlockingPostingStepHeaderViewDelegate: class {
    func didTapStepHeaderView()
}

class BlockingPostingStepHeaderView: UIView {
    
    static let height: CGFloat = 100
    
    private static let circleHeight: CGFloat = 30
    private static let titleHeight: CGFloat = 41
    
    private let titleLabel = UILabel()
    private let circleView = UIView()
    private let stepNumberLabel = UILabel()
    
    weak var delegate: BlockingPostingStepHeaderViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    func updateWith(stepNumber: Int, title: String) {
        titleLabel.text = title
        stepNumberLabel.text = String(stepNumber)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        circleView.backgroundColor = UIColor.primaryColor
        circleView.layer.cornerRadius = BlockingPostingStepHeaderView.circleHeight/2
        
        stepNumberLabel.textColor = .white
        stepNumberLabel.textAlignment = .center
        stepNumberLabel.font = UIFont.systemBoldFont(size: 17)
        
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemBoldFont(size: 35)
        
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        addGestureRecognizer(tapBackground)
    }
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([titleLabel, circleView])
        
        circleView.layout(with: self)
            .top(by: Metrics.bigMargin)
            .leading(by: Metrics.bigMargin)
        circleView.layout()
            .height(BlockingPostingStepHeaderView.circleHeight)
            .widthProportionalToHeight()
        
        titleLabel.layout(with: self).fillHorizontal(by: Metrics.bigMargin)
        titleLabel.layout().height(BlockingPostingStepHeaderView.titleHeight)
        titleLabel.layout(with: circleView).top(to: .bottomMargin, by: Metrics.shortMargin)
        
        stepNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(stepNumberLabel)
        stepNumberLabel.layout(with: circleView).fill()
    }
    
    
    // MARK: - UI Actions
    
    @objc private func closeKeyboard() {
        delegate?.didTapStepHeaderView()
    }
}
