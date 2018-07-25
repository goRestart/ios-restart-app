import Foundation
import LGComponents

enum ReportUpdateButtonType: Int {
    case verySad
    case sad
    case neutral
    case happy
    case veryHappy

    private var image: UIImage {
        switch self {
        case .verySad: return R.Asset.Reporting.feedbackVerySad.image
        case .sad: return R.Asset.Reporting.feedbackSad.image
        case .neutral: return R.Asset.Reporting.feedbackNeutral.image
        case .happy: return R.Asset.Reporting.feedbackHappy.image
        case .veryHappy: return R.Asset.Reporting.feedbackVeryHappy.image
        }
    }

    private var disabledImage: UIImage {
        switch self {
        case .verySad: return R.Asset.Reporting.feedbackVerySadDisabled.image
        case .sad: return R.Asset.Reporting.feedbackSadDisabled.image
        case .neutral: return R.Asset.Reporting.feedbackNeutralDisabled.image
        case .happy: return R.Asset.Reporting.feedbackHappyDisabled.image
        case .veryHappy: return R.Asset.Reporting.feedbackVeryHappyDisabled.image
        }
    }

    var selectedStateImage: UIImage {
        return image.af_imageAspectScaled(toFit: CGSize(width: 49, height: 49))
    }

    var disabledStateImage: UIImage {
        return disabledImage.af_imageAspectScaled(toFit: CGSize(width: 38, height: 38))
    }

    var normalStateImage: UIImage {
        return image.af_imageAspectScaled(toFit: CGSize(width: 38, height: 38))
    }
}

final class ReportUpdateButton: UIButton {

    private let type: ReportUpdateButtonType

    init(type: ReportUpdateButtonType) {
        self.type = type
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setImage(type.normalStateImage, for: .normal)
        setImage(type.selectedStateImage, for: .selected)
        setImage(type.disabledStateImage, for: .disabled)
    }
}
