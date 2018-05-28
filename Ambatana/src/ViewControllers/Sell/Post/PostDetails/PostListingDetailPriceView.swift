import UIKit
import RxSwift
import RxCocoa
import LGComponents

class PostListingDetailPriceView: BaseView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var priceViewContainer: UIView!
    @IBOutlet weak var priceFieldContainer: UIView!
    @IBOutlet weak var postFreeViewContainer: UIView!
    @IBOutlet weak var doneButton: LetgoButton!
    
    @IBOutlet weak var freePostSwitch: UISwitch!
    @IBOutlet weak var giveAwayContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorContainerDistanceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var priceContainerHeightConstraint: NSLayoutConstraint!
    
    static let separatorContainerDistance: CGFloat = 1
    static let containerHeight: CGFloat = 55
    
    @IBOutlet weak var freePostLabel: UILabel!
    private let viewModel: PostListingBasicDetailViewModel

    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: PostListingBasicDetailViewModel) {
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }

    init(viewModel: PostListingBasicDetailViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setup()
    }

    init?(viewModel: PostListingBasicDetailViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        guard let priceTextField = priceTextField else { return false }
        return priceTextField.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        guard let priceTextField = priceTextField else { return false }
        return priceTextField.resignFirstResponder()
    }

    private func setup() {
        loadNibNamed("PostListingDetailPriceView", contentView: { [weak self] in return self?.contentView })
        setupUI()
        setAccesibilityIds()
        setupRx()
    }

    private func setupUI() {
        infoLabel.text = R.Strings.productPostPriceLabel.localizedUppercase
        priceViewContainer.cornerRadius = 15.0
        postFreeViewContainer.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        freePostSwitch.isUserInteractionEnabled = false
        priceFieldContainer.backgroundColor = UIColor(white: 0.9, alpha: 0.3)
        freePostLabel.text = R.Strings.sellPostFreeLabel
        freePostLabel.textColor = UIColor.white
        priceTextField.attributedPlaceholder = NSAttributedString(string: R.Strings.productNegotiablePrice,
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        doneButton.setTitle(R.Strings.productPostDone, for: .normal)
        currencyLabel.text = viewModel.currencySymbol
        currencyLabel.textColor = UIColor.white
        doneButton.setStyle(.primary(fontSize: .big))
        showFreeOption(viewModel.freeOptionAvailable)

        let tap = UITapGestureRecognizer(target: self, action: #selector(freeCellPressed))
        postFreeViewContainer.addGestureRecognizer(tap)
    }

    private func setupRx() {
        priceTextField.rx.text.asObservable().map { $0 ?? "" }.bind(to: viewModel.price).disposed(by: disposeBag)
        viewModel.isFree.asObservable().bind(to: freePostSwitch.rx.isOn).disposed(by: disposeBag)
        viewModel.isFree.asObservable().bind {[weak self] active in
            self?.showPriceTextContainer(!active)
            }.disposed(by: disposeBag)
        doneButton.rx.tap.bind { [weak self] in
            self?.priceTextField.resignFirstResponder()
            self?.viewModel.doneButtonPressed()
        }.disposed(by: disposeBag)
    }
    
    private func showFreeOption(_ show: Bool) {
        if show {
            giveAwayContainerHeightConstraint.constant = PostListingDetailPriceView.containerHeight
            separatorContainerDistanceConstraint.constant = PostListingDetailPriceView.separatorContainerDistance
        } else {
            giveAwayContainerHeightConstraint.constant = 0
            separatorContainerDistanceConstraint.constant = 0
        }
    }
    private func showPriceTextContainer(_ show: Bool) {
        if show {
            priceContainerHeightConstraint.constant = PostListingDetailPriceView.containerHeight
            separatorContainerDistanceConstraint.constant = PostListingDetailPriceView.separatorContainerDistance
        } else {
            priceContainerHeightConstraint.constant = 0
            separatorContainerDistanceConstraint.constant = 0
            priceTextField.resignFirstResponder()
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        } )
    }

    @objc private func freeCellPressed() {
        viewModel.freeCellPressed()
    }
}


// MARK: - UITextFieldDelegate

extension PostListingDetailPriceView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == priceTextField else { return true }
        return textField.shouldChangePriceInRange(range, replacementString: string, acceptsSeparator: true)
    }
}


// MARK: - Accesibility

extension PostListingDetailPriceView {
    func setAccesibilityIds() {
        doneButton.set(accessibilityId: .postingDoneButton)
        currencyLabel.set(accessibilityId: .postingCurrencyLabel)
        priceTextField.set(accessibilityId: .postingPriceField)
    }
}
