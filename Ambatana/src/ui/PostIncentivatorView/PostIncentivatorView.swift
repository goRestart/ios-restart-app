import UIKit
import LGComponents
import RxSwift
import RxCocoa

protocol PostIncentivatorViewDelegate: class {
    func incentivatorTapped()
}

class PostIncentivatorView: UIView {

    @IBOutlet weak var incentiveLabel: UILabel!
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstCountLabel: UILabel!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var secondCountLabel: UILabel!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var thirdNameLabel: UILabel!
    @IBOutlet weak var thirdCountLabel: UILabel!
    @IBOutlet var magnifyingGlass: [UIImageView]!
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onTap))
    }()

    weak var delegate: PostIncentivatorViewDelegate?

    var isFree: Bool?
    private var isServicesListing: Bool = false

    var incentiveText: NSAttributedString {
        if isServicesListing {
            return servicesIncentiveText()
        }
        
        return defaultIncentiveText()
    }
    
    private let featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance


    // MARK: - Lifecycle

    static func postIncentivatorView(_ isFree: Bool,
                                     isServicesListing: Bool) -> PostIncentivatorView {
        guard let view = Bundle.main.loadNibNamed("PostIncentivatorView", owner: self, options: nil)?.first
            as? PostIncentivatorView else { return PostIncentivatorView() }
        view.isFree = isFree
        view.isServicesListing = isServicesListing
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }


    // MARK: - Public methods

    func setupIncentiviseView() {
        for imageView in magnifyingGlass {
            imageView.image = R.Asset.CongratsScreenImages.icMagnifier.image
        }
        
        let itemPack = getIncentiviserPack()

        guard itemPack.count == 3 else {
            self.isHidden = true
            return
        }

        let firstItem = itemPack[0]
        let secondItem = itemPack[1]
        let thirdItem = itemPack[2]

        firstImage.image = firstItem.image
        firstNameLabel.text = firstItem.name
        firstNameLabel.textColor = UIColor.blackText
        firstCountLabel.text = firstItem.searchCount
        firstCountLabel.textColor = UIColor.darkGrayText

        secondImage.image = secondItem.image
        secondNameLabel.text = secondItem.name
        secondNameLabel.textColor = UIColor.blackText
        secondCountLabel.text = secondItem.searchCount
        secondCountLabel.textColor = UIColor.darkGrayText

        thirdImage.image = thirdItem.image
        thirdNameLabel.text = thirdItem.name
        thirdNameLabel.textColor = UIColor.blackText
        thirdCountLabel.text = thirdItem.searchCount
        thirdCountLabel.textColor = UIColor.darkGrayText

        incentiveLabel.attributedText = incentiveText

        addGestureRecognizer(tapGesture)
    }
    
    private func getIncentiviserPack() -> [PostIncentiviserItem] {
        if isServicesListing {
            return PostIncentiviserItem.servicesIncentiviserPack()
        }
        
        return PostIncentiviserItem.incentiviserPack(isFree ?? false)
    }


    // MARK: - Private methods

    @objc private func onTap() {
        delegate?.incentivatorTapped()
    }
    
    
    // MARK: Attributed Strings
    
    private func defaultIncentiveText() -> NSAttributedString {
        let gotAnyTextAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.darkGrayText,
                                                                   NSAttributedStringKey.font : UIFont.systemBoldFont(size: 15)]
        let lookingForTextAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.darkGrayText,
                                                                       NSAttributedStringKey.font : UIFont.mediumBodyFont]
        
        let secondPartString = (isFree ?? false)  ? R.Strings.productPostIncentiveGotAnyFree :
            R.Strings.productPostIncentiveGotAny
        let plainText = R.Strings.productPostIncentiveLookingFor(secondPartString)
        let resultText = NSMutableAttributedString(string: plainText, attributes: lookingForTextAttributes)
        let boldRange = NSString(string: plainText).range(of: secondPartString, options: .caseInsensitive)
        resultText.addAttributes(gotAnyTextAttributes, range: boldRange)
        
        return resultText
    }
    
    private func servicesIncentiveText() -> NSAttributedString {
        
        let lookingForTextAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.darkGrayText,
                                                                       NSAttributedStringKey.font : UIFont.mediumBodyFont]
        let gotAnyTextAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor : UIColor.darkGrayText,
                                                                   NSAttributedStringKey.font : UIFont.systemBoldFont(size: 15)]
        let secondPartString = featureFlags.jobsAndServicesEnabled.isActive ? R.Strings.postDetailsJobsServicesCongratulationPeopleNearbySecond :
            R.Strings.productPostIncentiveGotAnyServices
        
        let baseText = featureFlags.jobsAndServicesEnabled.isActive ? (R.Strings.postDetailsJobsServicesCongratulationPeopleNearbyFirst + " \(secondPartString)") :
            R.Strings.productPostIncentiveLookingForServices(secondPartString)
        
        let resultText = NSMutableAttributedString(string: baseText, attributes: lookingForTextAttributes)
        let boldRange = NSString(string: baseText).range(of: secondPartString, options: .caseInsensitive)
        resultText.addAttributes(gotAnyTextAttributes, range: boldRange)
        
        return resultText
    }
}

extension Reactive where Base: PostIncentivatorView {
    var viewTapped: ControlEvent<UITapGestureRecognizer> {
        return base.tapGesture.rx.event
    }
}
