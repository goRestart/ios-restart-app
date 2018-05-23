import UIKit
import LGComponents

protocol FilterCarInfoYearCellDelegate: class {
    func filterYearChanged(withStartYear startYear: Int?, endYear: Int?)
}

class FilterSliderYearCell: UICollectionViewCell, LGSliderDelegate, ReusableCell {
    var slider: LGSlider?
    
    weak var delegate: FilterCarInfoYearCellDelegate?
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setAccessibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    func setupSlider(minimumValue: Int,
                     maximumValue: Int,
                     minimumValueSelected: Int?,
                     maximumValueSelected: Int?) {
        
        let vm = LGSliderViewModel(title: R.Strings.postCategoryDetailCarYear,
                                   minimumValueNotSelectedText: R.Strings.filtersCarYearBeforeYear(minimumValue),
                                   maximumValueNotSelectedText: String(maximumValue),
                                   minimumAndMaximumValuesNotSelectedText: R.Strings.filtersCarYearAnyYear,
                                   minimumValue: minimumValue,
                                   maximumValue: maximumValue,
                                   minimumValueSelected: minimumValueSelected,
                                   maximumValueSelected: maximumValueSelected)
        slider = LGSlider(viewModel: vm)
        guard let slider = self.slider else { return }
        slider.delegate = self
        slider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(slider)
        slider.layout(with: contentView)
            .left(by: Metrics.margin)
            .right(by: -Metrics.margin)
            .top()
            .bottom()
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        _ = addTopBorderWithWidth(LGUIKitConstants.onePixelSize, color: UIColor.gray)
        _ = addBottomBorderWithWidth(LGUIKitConstants.onePixelSize, color: UIColor.gray)
        backgroundColor = UIColor.white
    }
    
    private func resetUI() {
        slider?.resetSelection()
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId: .filterCarInfoYearCell)
        slider?.titleLabel.set(accessibilityId: .filterCarInfoYearCellTitleLabel)
        slider?.selectionLabel.set(accessibilityId: .filterCarInfoYearCellInfoLabel)
    }
    
    
    // MARK: - LGSLiderDelegate

    func slider(_ slider: LGSlider, didSelectMinimumValue minimumValue: Int) {
        delegate?.filterYearChanged(withStartYear: minimumValue, endYear: nil)
    }
    
    func slider(_ slider: LGSlider, didSelectMaximumValue maximumValue: Int) {
        delegate?.filterYearChanged(withStartYear: nil, endYear: maximumValue)
    }
}
