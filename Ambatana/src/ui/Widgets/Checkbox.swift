import UIKit
import LGComponents

final class Checkbox: UIButton {

    private static let checkedImage = R.Asset.IconsButtons.icCheckboxSelected.image
    private static let uncheckedImage = R.Asset.IconsButtons.icCheckbox.image

    var isChecked: Bool = false {
        didSet{ setImage(isChecked ? Checkbox.checkedImage : Checkbox.uncheckedImage, for: .normal) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isChecked = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
