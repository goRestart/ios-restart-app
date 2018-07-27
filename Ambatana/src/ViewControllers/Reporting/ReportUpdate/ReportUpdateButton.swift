import Foundation
import LGComponents

enum ReportUpdateButtonType: Int {
    case verySad
    case sad
    case neutral
    case happy
    case veryHappy

    var image: UIImage {
        switch self {
        case .verySad: return R.Asset.Reporting.feedbackVerySad.image
        case .sad: return R.Asset.Reporting.feedbackSad.image
        case .neutral: return R.Asset.Reporting.feedbackNeutral.image
        case .happy: return R.Asset.Reporting.feedbackHappy.image
        case .veryHappy: return R.Asset.Reporting.feedbackVeryHappy.image
        }
    }

    var disabledImage: UIImage {
        switch self {
        case .verySad: return R.Asset.Reporting.feedbackVerySadDisabled.image
        case .sad: return R.Asset.Reporting.feedbackSadDisabled.image
        case .neutral: return R.Asset.Reporting.feedbackNeutralDisabled.image
        case .happy: return R.Asset.Reporting.feedbackHappyDisabled.image
        case .veryHappy: return R.Asset.Reporting.feedbackVeryHappyDisabled.image
        }
    }
//
//    var selectedStateImage: UIImage {
//        return image.af_imageAspectScaled(toFit: CGSize(width: 49, height: 49))
//    }
//
//    var disabledStateImage: UIImage {
//        return disabledImage.af_imageAspectScaled(toFit: CGSize(width: 38, height: 38))
//    }
//
//    var normalStateImage: UIImage {
//        return image.af_imageAspectScaled(toFit: CGSize(width: 38, height: 38))
//    }
}

final class ReportUpdateButton: UIButton {

    private let type: ReportUpdateButtonType

    init(type: ReportUpdateButtonType) {
        self.type = type
        let frame = CGRect(x: 0, y: 0, width: 38, height: 38)
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setImage(type.image, for: .normal)
    }

    func set(selected: Bool) {
        if selected {
            self.setImage(self.type.image.af_imageAspectScaled(toFit: CGSize(width: 49, height: 49)), for: .normal)
            shake(times: 2, currentTimes: 0, direction: -1, duration: 0.1, delta: 3)
        } else {
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.setImage(self.type.disabledImage, for: .normal)
            }, completion: nil)
        }
    }

    private func shake(times: Int, currentTimes: Int, direction: CGFloat, duration: TimeInterval, delta: CGFloat) {
        UIView.animate(withDuration: duration, animations: {
            let translation = CGAffineTransform.init(translationX: delta * direction, y: delta * direction)
            self.layer.setAffineTransform(translation)
        }) { (completed) in
            if currentTimes >= times {
                UIView.animate(withDuration: duration/2, animations: {
                    self.layer.setAffineTransform(CGAffineTransform.identity)
                }, completion: nil)
                return
            }
            self.shake(times: times, currentTimes: currentTimes+1, direction: direction * -1, duration: duration, delta: delta * 0.4)
        }
    }
}

