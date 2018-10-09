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

    private let shareOnFacebookView: ShareOnFacebookView
    
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
        self.shareOnFacebookView = ShareOnFacebookView(viewModel: viewModel)
        super.init(viewModel: viewModel, frame: frame)
        setup()
    }

    init?(viewModel: PostListingBasicDetailViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        self.shareOnFacebookView = ShareOnFacebookView(viewModel: viewModel)
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

        setupShareOnFacebook()
    }

    private func setupShareOnFacebook() {
        addSubviewForAutoLayout(shareOnFacebookView)
        NSLayoutConstraint.activate([
            shareOnFacebookView.topAnchor.constraint(equalTo: priceViewContainer.bottomAnchor, constant: Metrics.margin),
            shareOnFacebookView.leftAnchor.constraint(equalTo: priceViewContainer.leftAnchor),
            shareOnFacebookView.rightAnchor.constraint(equalTo: priceViewContainer.rightAnchor),
            shareOnFacebookView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -Metrics.margin)
        ])
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

final class ShareOnFacebookView: BaseView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bigBodyFont
        label.textColor = UIColor.white
        label.text = R.Strings.sellShareOnFacebookLabel
        label.textAlignment = .center
        return label
    }()
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.smallBodyFont
        label.textColor = UIColor.white
        label.text = R.Strings.sellShareOnFacebookFooterLabel
        label.textAlignment = .center
        return label
    }()
    private let checkbox: Checkbox = Checkbox()
    private let titleAndCheckboxContainerView: UIView = UIView()

    private let viewModel: PostListingBasicDetailViewModel
    private let disposeBag = DisposeBag()

    convenience init(viewModel: PostListingBasicDetailViewModel) {
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }

    init(viewModel: PostListingBasicDetailViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        setupUI()
    }

    init?(viewModel: PostListingBasicDetailViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleAndCheckboxContainerView.addSubviewsForAutoLayout([titleLabel, checkbox])
        addSubviewsForAutoLayout([titleAndCheckboxContainerView, footerLabel])
        setupConstraints()
        setupRX()
        setAccesibilityIds()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleAndCheckboxContainerView.topAnchor.constraint(equalTo: topAnchor),
            titleAndCheckboxContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            titleAndCheckboxContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: titleAndCheckboxContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: titleAndCheckboxContainerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleAndCheckboxContainerView.bottomAnchor),

            checkbox.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            checkbox.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Metrics.shortMargin),
            checkbox.trailingAnchor.constraint(equalTo: titleAndCheckboxContainerView.trailingAnchor),

            footerLabel.topAnchor.constraint(equalTo: titleAndCheckboxContainerView.bottomAnchor, constant: Metrics.shortMargin),
            footerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        checkbox.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        checkbox.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    private func setupRX() {
        viewModel.shareOnFacebook.asObservable().bind { [weak self] shareOnFacebook in
            self?.checkbox.isChecked = shareOnFacebook
        }.disposed(by: disposeBag)
        checkbox.rx.tap.bind { [weak self] in
            self?.viewModel.shareOnFacebookPressed()
        }.disposed(by: disposeBag)
    }

    private func setAccesibilityIds() {
        titleLabel.set(accessibilityId: .postingDetailShareOnFacebookTitleLabel)
        footerLabel.set(accessibilityId: .postingDetailShareOnFacebookFooterLabel)
        checkbox.set(accessibilityId: .postingDetailShareOnFacebookCheckbox)
    }
}
