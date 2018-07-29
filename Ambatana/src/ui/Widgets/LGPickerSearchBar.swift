import UIKit
import LGComponents

final class LGPickerSearchBar: UISearchBar {
    
    init(withStyle style: CategoryDetailStyle) {
        super.init(frame: CGRect.zero)
        setupStyling(forStyle: style)
        setupTextField(forStyle: style, clearButtonMode: .never)
    }
    
    init(withStyle style: CategoryDetailStyle,
         clearButtonMode: UITextFieldViewMode) {
        super.init(frame: CGRect.zero)
        setupStyling(forStyle: style)
        setupTextField(forStyle: style, clearButtonMode: clearButtonMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStyling(forStyle style: CategoryDetailStyle) {
        autocapitalizationType = .none
        autocorrectionType = .no
        barStyle = .default
        barTintColor = .clear
        backgroundColor = nil
        tintColor = UIColor.redText
        let imageWithColor = UIImage.imageWithColor(style.searchBackgroundColor,
                                                    size: CGSize(width: Metrics.screenWidth-Metrics.margin*2, height: 44))
        let searchBarBackground = UIImage.roundedImage(image: imageWithColor, cornerRadius: 10)
        setSearchFieldBackgroundImage(nil, for: .normal)
        setBackgroundImage(searchBarBackground, for: .any, barMetrics: .default)
        searchTextPositionAdjustment = UIOffsetMake(10, 0)
    }
    
    private func setupTextField(forStyle style: CategoryDetailStyle, clearButtonMode: UITextFieldViewMode) {
        if let textField: UITextField = firstSubview(ofType: UITextField.self) {
            textField.font = UIFont.bigBodyFont
            textField.clearButtonMode = clearButtonMode
            textField.backgroundColor = .clear
            textField.textColor = style.searchTextColor
            textField.attributedPlaceholder =
                NSAttributedString(string: R.Strings.postCategoryDetailSearchPlaceholder,
                                   attributes: [NSAttributedStringKey.foregroundColor: style.placeholderTextColor])
            if let iconSearchImageView = textField.leftView as? UIImageView {
                iconSearchImageView.image = iconSearchImageView.image?.withRenderingMode(.alwaysTemplate)
                iconSearchImageView.tintColor = style.searchIconColor
            }
        }
    }
}
