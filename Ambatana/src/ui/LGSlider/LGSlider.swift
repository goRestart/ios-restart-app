import UIKit
import LGComponents


protocol LGSliderDelegate: class {
    func slider(_ slider: LGSlider, didSelectMinimumValue minimumValue: Int)
    func slider(_ slider: LGSlider, didSelectMaximumValue maximumValue: Int)
}


class LGSlider: UIView, LGSliderDataSource {
    
    static let thumbSize: CGFloat = 30
    private let viewModel: LGSliderViewModel
    
    private let leftThumb = LGSliderThumb(image: R.Asset.IconsButtons.icChevronRight.image)
    private let rightThumb = LGSliderThumb(image: R.Asset.IconsButtons.icChevronRight.image, rotate: true)
    
    private let disabledBarView = UIView()
    private let enabledBarView = UIView()
    
    let titleLabel = UILabel()
    let selectionLabel = UILabel()
    
    private var shouldUpdateThumbConstraints: Bool = true
    
    weak var delegate: LGSliderDelegate?
    
    // MARK: - Lifecycle
    
    init(viewModel: LGSliderViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        setupGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        backgroundColor = UIColor.white
        
        leftThumb.dataSource = self
        rightThumb.dataSource = self
        
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
                        leftThumb.imageView, rightThumb.imageView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: allViews)
        addSubviews(allViews)
        
        titleLabel.layout(with: self)
            .left()
            .top(by: 10)
        titleLabel.layout(with: selectionLabel)
            .left(to: .right, by: -10, relatedBy: .lessThanOrEqual)
        selectionLabel.layout(with: self)
            .right()
            .top(by: 10)
        
        disabledBarView.layout().height(2)
        disabledBarView.layout(with: self)
            .left(by: LGSlider.thumbSize)
            .right(by: -LGSlider.thumbSize)
            .bottom(by: -25)
        enabledBarView.layout(with: disabledBarView)
            .top()
            .bottom()
        enabledBarView.layout(with: leftThumb.imageView)
            .left(to: .right)
        enabledBarView.layout(with: rightThumb.imageView)
            .right(to: .left)
        
        leftThumb.imageView.layout()
            .width(LGSlider.thumbSize)
            .widthProportionalToHeight()
        leftThumb.imageView.layout(with: disabledBarView)
            .centerY()
            .right(to: .left) { [weak self] in
                self?.leftThumb.constraint = $0
        }
        
        leftThumb.imageView.layout(with: rightThumb.imageView)
            .right(to: .left, relatedBy: .lessThanOrEqual)
        
        rightThumb.imageView.layout()
            .width(LGSlider.thumbSize)
            .widthProportionalToHeight()
        rightThumb.imageView.layout(with: disabledBarView)
            .centerY()
            .left(to: .right) { [weak self] in
                self?.rightThumb.constraint = $0
        }
    }
    
    private func setupGestures() {
        let views = [leftThumb.touchableView, rightThumb.touchableView]
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: views)
        addSubviews(views)
        leftThumb.touchableView.layout(with: leftThumb.imageView)
            .left(by: -15)
            .right()
            .top(by: -10)
            .bottom(by: 10)
        rightThumb.touchableView.layout(with: rightThumb.imageView)
            .left()
            .right(by: 15)
            .top(by: -10)
            .bottom(by: 10)
        
        let leftGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressThumb(gesture:)))
        leftGesture.minimumPressDuration = 0
        leftThumb.touchableView.addGestureRecognizer(leftGesture)
        
        let rightGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressThumb(gesture:)))
        rightGesture.minimumPressDuration = 0
        rightThumb.touchableView.addGestureRecognizer(rightGesture)
    }
    
    private func updateUI() {
        selectionLabel.text = viewModel.selectionLabelText()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateThumbConstraintsIfNeeded()
    }
    
    
    // MARK: - Actions
    
    @objc func didPressThumb(gesture: UILongPressGestureRecognizer) {
        guard let viewPressed = gesture.view else { return }
        guard let thumb: LGSliderThumb =
            viewPressed == leftThumb.touchableView ? leftThumb :
                viewPressed == rightThumb.touchableView ? rightThumb : nil
            else { return }
        
        switch gesture.state {
        case .began:
            thumb.isDragging = true
            thumb.previousLocationInView = gesture.location(in: self)
        case .changed:
            let locationInView = gesture.location(in: self)
            let movementAcrossXAxis = locationInView.x - thumb.previousLocationInView.x
            handleThumbTouch(thumb: thumb, movementAcrossXAxis: movementAcrossXAxis)
            thumb.previousLocationInView = locationInView
        case .ended, .cancelled, .failed:
            stopDragging()
        default:
            break
        }
    }
    
    private func handleThumbTouch(thumb: LGSliderThumb, movementAcrossXAxis movement: CGFloat) {
        var constant = thumb.constraint.constant + movement
        let minimumConstant = thumb.minimumConstraintConstant
        let maximumConstant = thumb.maximumConstraintConstant
        if constant < minimumConstant {
            constant = minimumConstant
        } else if constant > maximumConstant {
            constant = maximumConstant
        }
        thumb.constraint.constant = constant
        
        if thumb === leftThumb {
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
        leftThumb.constraint.constant = 0
        rightThumb.constraint.constant = 0
        viewModel.resetSelection()
        updateUI()
    }
    
    func setMinimumValueSelected(_ value: Int) {
        viewModel.minimumValueSelected = value
        updateUI()
        
        shouldUpdateThumbConstraints = true
        setNeedsLayout()
    }
    
    func setMaximumValueSelected(_ value: Int) {
        viewModel.maximumValueSelected = value
        updateUI()
        
        shouldUpdateThumbConstraints = true
        setNeedsLayout()
    }
    
    private func stopDragging() {
        if leftThumb.isDragging {
            leftThumb.isDragging = false
            delegate?.slider(self, didSelectMinimumValue: viewModel.minimumValueSelected)
        }
        if rightThumb.isDragging {
            rightThumb.isDragging = false
            delegate?.slider(self, didSelectMaximumValue: viewModel.maximumValueSelected)
        }
    }
    
    private func updateThumbConstraintsIfNeeded() {
        guard shouldUpdateThumbConstraints else { return }
        shouldUpdateThumbConstraints = false
        leftThumb.constraint.constant = viewModel.constant(forValue: viewModel.minimumValueSelected,
                                                              minimumConstant: 0,
                                                              maximumConstant: disabledBarView.frame.width)
        rightThumb.constraint.constant = viewModel.constant(forValue: viewModel.maximumValueSelected,
                                                               minimumConstant: -disabledBarView.frame.width,
                                                               maximumConstant: 0)
    }
    
    
    // MARK: - LGSliderDataSource
    
    func minimumConstraintConstant(sliderThumb: LGSliderThumb) -> CGFloat {
        if sliderThumb === leftThumb {
            return 0
        } else {
            return -(disabledBarView.frame.maxX - leftThumb.imageView.frame.maxX)
        }
    }
    
    func maximumConstraintConstant(sliderThumb: LGSliderThumb) -> CGFloat {
        if sliderThumb === leftThumb {
            return rightThumb.imageView.frame.minX - disabledBarView.frame.minX
        } else {
            return 0
        }
    }
}
