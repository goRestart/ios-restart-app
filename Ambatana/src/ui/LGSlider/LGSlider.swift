//
//  LGSlider.swift
//  LetGo
//
//  Created by Nestor on 04/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit


protocol LGSliderDelegate: class {
    func slider(_ slider: LGSlider, didSelectMinimumValue minimumValue: Int)
    func slider(_ slider: LGSlider, didSelectMaximumValue maximumValue: Int)
}


class LGSlider: UIView, LGSliderDataSource {
    
    static let selectorSize: CGFloat = 34
    private let viewModel: LGSliderViewModel
    
    private let leftSelector = LGSliderSelector(image: #imageLiteral(resourceName: "ic_chevron_right"))
    private let rightSelector = LGSliderSelector(image: #imageLiteral(resourceName: "ic_chevron_right"), rotate: true)
    
    private let disabledBarView = UIView()
    private let enabledBarView = UIView()
    
    private let titleLabel = UILabel()
    private let selectionLabel = UILabel()
    
    private var shouldUpdateSelectorConstraints: Bool = false
    
    weak var delegate: LGSliderDelegate?
    
    
    // MARK: - Lifecycle
    
    init(viewModel: LGSliderViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = UIColor.white
        
        leftSelector.dataSource = self
        leftSelector.addTarget(self, action: #selector(didPressSelector(_:)), for: UIControlEvents.allEvents)
        rightSelector.dataSource = self
//        let button = UIButton(type: .custom)
//        button.addTarget(self, action: #selector(didPressSelector(_:)), for: UIControlEvents.allEvents)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(button)
//        button.layout(with: self).fill()
        
        disabledBarView.backgroundColor = UIColor.gray
        enabledBarView.backgroundColor = UIColor.primaryColor
        
        titleLabel.text = viewModel.title
        titleLabel.textAlignment = .left
        selectionLabel.textColor = UIColor.gray
        selectionLabel.textAlignment = .right
        selectionLabel.text = viewModel.selectionLabelText()
    }
    
    private func setupConstraints() {
        let allViews = [titleLabel, selectionLabel,
                        disabledBarView, enabledBarView,
                        leftSelector.imageView!, rightSelector.imageView!]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: allViews)
        addSubviews(allViews)
        
        titleLabel.layout(with: self)
            .left()
            .top(by: 10)
        titleLabel.layout(with: selectionLabel)
            .left(to: .right, by: -10, relatedBy: .lessThanOrEqual)
        titleLabel.layout(with: disabledBarView)
            .bottom(to: .top, by: -25)
        selectionLabel.layout(with: self)
            .right()
            .top(by: 10)
        
        disabledBarView.layout().height(2)
        disabledBarView.layout(with: self)
            .left(by: LGSlider.selectorSize)
            .right(by: -LGSlider.selectorSize)
            .bottom(by: -25)
        enabledBarView.layout(with: disabledBarView)
            .top()
            .bottom()
        enabledBarView.layout(with: leftSelector.imageView!)
            .left(to: .right)
        enabledBarView.layout(with: rightSelector.imageView!)
            .right(to: .left)
        
        leftSelector.imageView!.layout()
            .width(LGSlider.selectorSize)
            .widthProportionalToHeight()
        leftSelector.imageView!.layout(with: disabledBarView)
            .centerY()
            .right(to: .left) { [weak self] in
                self?.leftSelector.constraint = $0
        }
        
        leftSelector.imageView!.layout(with: rightSelector.imageView!)
            .right(to: .left, relatedBy: .lessThanOrEqual)
        
        rightSelector.imageView!.layout()
            .width(LGSlider.selectorSize)
            .widthProportionalToHeight()
        rightSelector.imageView!.layout(with: disabledBarView)
            .centerY()
            .left(to: .right) { [weak self] in
                self?.rightSelector.constraint = $0
        }
    }
    
    private func updateUI() {
        selectionLabel.text = viewModel.selectionLabelText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateSelectorConstraintsIfNeeded()
    }
    
    
    // MARK: - Actions
    
    private func handleSelectorTouch(selector: LGSliderSelector, movementAcrossXAxis movement: CGFloat) {
        var constant = selector.constraint.constant + movement
        let minimumConstant = selector.minimumConstraintConstant
        let maximumConstant = selector.maximumConstraintConstant
        if constant < minimumConstant {
            constant = minimumConstant
        } else if constant > maximumConstant {
            constant = maximumConstant
        }
        selector.constraint.constant = constant
        
        if selector === leftSelector {
            viewModel.minimumValueSelected = viewModel.value(forConstant: constant,
                                                             minimumConstant: 0,
                                                             maximumConstant: disabledBarView.frame.width)
        } else {
            viewModel.maximumValueSelected = viewModel.value(forConstant: constant,
                                                             minimumConstant: -disabledBarView.frame.width,
                                                             maximumConstant: 0)
        }
        updateUI()
    }
    
    
    // MARK: - Helpers
    
    func resetSelection() {
        leftSelector.constraint.constant = 0
        rightSelector.constraint.constant = 0
        viewModel.resetSelection()
        updateUI()
    }
    
    func setMinimumValueSelected(_ value: Int) {
        viewModel.minimumValueSelected = value
        updateUI()
        
        shouldUpdateSelectorConstraints = true
        setNeedsLayout()
    }
    
    func setMaximumValueSelected(_ value: Int) {
        viewModel.maximumValueSelected = value
        updateUI()
        
        shouldUpdateSelectorConstraints = true
        setNeedsLayout()
    }
    
    private func stopDragging() {
        if leftSelector.isDragging {
            leftSelector.isDragging = false
            delegate?.slider(self, didSelectMinimumValue: viewModel.minimumValueSelected)
        }
        if rightSelector.isDragging {
            rightSelector.isDragging = false
            delegate?.slider(self, didSelectMaximumValue: viewModel.maximumValueSelected)
        }
    }
    
    private func updateSelectorConstraintsIfNeeded() {
        if shouldUpdateSelectorConstraints {
            shouldUpdateSelectorConstraints = false
            leftSelector.constraint.constant = viewModel.constant(forValue: viewModel.minimumValueSelected,
                                                                  minimumConstant: 0,
                                                                  maximumConstant: disabledBarView.frame.width)
            rightSelector.constraint.constant = viewModel.constant(forValue: viewModel.maximumValueSelected,
                                                                   minimumConstant: -disabledBarView.frame.width,
                                                                   maximumConstant: 0)
        }
    }
    
    
    // MARK: - LGSliderDataSource
    
    func minimumConstraintConstant(sliderSelector: LGSliderSelector) -> CGFloat {
        if sliderSelector === leftSelector {
            return 0
        } else {
            return -(disabledBarView.frame.maxX - leftSelector.imageView!.frame.maxX)
        }
    }
    
    func maximumConstraintConstant(sliderSelector: LGSliderSelector) -> CGFloat {
        if sliderSelector === leftSelector {
            return rightSelector.imageView!.frame.minX - disabledBarView.frame.minX
        } else {
            return 0
        }
    }
    
    
    // MARK: - UIResponderStandardEditActions
    
    dynamic func didPressSelector(_ sliderSelector: LGSliderSelector) {
        stopDragging()
        if sliderSelector === leftSelector {
            leftSelector.isDragging = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //stopDragging()
//        if let touch = touches.first {
//            let locationInView = touch.location(in: self)
//            var leftSelectorTouchableFrame = leftSelector.imageView!.frame
//            leftSelectorTouchableFrame.origin.y -= 10
//            leftSelectorTouchableFrame.size.height += 20
//            leftSelectorTouchableFrame.origin.x -= 10
//            leftSelectorTouchableFrame.size.width += 10
//            
//            var rightSelectorTouchableFrame = rightSelector.imageView!.frame
//            rightSelectorTouchableFrame.origin.y -= 10
//            rightSelectorTouchableFrame.size.height += 20
//            rightSelectorTouchableFrame.size.width += 10
//            
//            if leftSelectorTouchableFrame.contains(locationInView) {
//                leftSelector.isDragging = true
//            } else if rightSelectorTouchableFrame.contains(locationInView) {
//                rightSelector.isDragging = true
//            }
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let locationInView = touch.location(in: self)
            let previousLocationInView = touch.previousLocation(in: self)
            let movementAcrossXAxis = locationInView.x - previousLocationInView.x
            
            if leftSelector.isDragging {
                handleSelectorTouch(selector: leftSelector, movementAcrossXAxis: movementAcrossXAxis)
            } else if rightSelector.isDragging {
                handleSelectorTouch(selector: rightSelector, movementAcrossXAxis: movementAcrossXAxis)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopDragging()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopDragging()
    }
}
