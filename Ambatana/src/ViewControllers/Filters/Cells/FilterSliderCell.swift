import UIKit
import LGComponents

final class FilterSliderCell: UICollectionViewCell, ReusableCell, FilterCell {
    
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    private var slider: LGSlider?
    
    private var minimumValueSelectedAction: ((Int) -> Void)?
    private var maximumValueSelectedAction: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.white
        addBottomSeparator(toContainerView: contentView)
    }
    
    private func resetUI() {
        slider?.resetSelection()
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .filterCarInfoYearCell)
        slider?.titleLabel.set(accessibilityId: .filterCarInfoYearCellTitleLabel)
        slider?.selectionLabel.set(accessibilityId: .filterCarInfoYearCellInfoLabel)
    }
    
    func setup(withViewModel viewModel: LGSliderViewModel,
               minimumValueSelectedAction: @escaping ((Int) -> Void),
               maximumValueSelectedAction: @escaping ((Int) -> Void)) {
        slider = LGSlider(viewModel: viewModel)
        slider?.delegate = self
        self.minimumValueSelectedAction = minimumValueSelectedAction
        self.maximumValueSelectedAction = maximumValueSelectedAction
        setupSliderConstraints()
    }
    
    private func setupSliderConstraints() {
        guard let slider = self.slider else { return }
        contentView.addSubviewForAutoLayout(slider)
        slider.layout(with: contentView)
            .fillHorizontal(by: Metrics.margin)
            .fillVertical()
    }
}

extension FilterSliderCell: LGSliderDelegate {
    
    func slider(_ slider: LGSlider,
                didSelectMinimumValue minimumValue: Int) {
        minimumValueSelectedAction?(minimumValue)
    }
    
    func slider(_ slider: LGSlider,
                didSelectMaximumValue maximumValue: Int) {
        maximumValueSelectedAction?(maximumValue)
    }
}
