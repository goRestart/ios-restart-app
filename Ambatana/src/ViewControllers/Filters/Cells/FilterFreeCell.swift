import RxSwift
import LGComponents

protocol FilterFreeCellDelegate: class {
    func freeSwitchChanged(isOn: Bool)
}

class FilterFreeCell: UICollectionViewCell, FilterCell, ReusableCell {
    var topSeparator: UIView?
    var bottomSeparator: UIView?
    var rightSeparator: UIView?

    let titleLabel = UILabel()
    let freeSwitch = UISwitch()

    weak var delegate: FilterFreeCellDelegate?
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRx()
        resetUI()
        setAccessibilityIds()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(freeSwitch)
        freeSwitch.translatesAutoresizingMaskIntoConstraints = false
        addTopSeparator(toContainerView: contentView)
        addBottomSeparator(toContainerView: contentView)

        let constraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            freeSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            freeSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            freeSwitch.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10)
        ]
        NSLayoutConstraint.activate(constraints)

        titleLabel.font = UIFont.systemFont(size: 16)
        titleLabel.textColor = UIColor.blackText
        freeSwitch.onTintColor = UIColor.primaryColor
    }
    
    private func setupRx() {
        freeSwitch.rx.value.asObservable().bind { [weak self] isOn in
            if let imageView = self?.freeSwitch.firstSubview(ofType: UIImageView.self) {
                imageView.contentMode = .center
                imageView.image = isOn ? R.Asset.IconsButtons.freeSwitchActive.image : R.Asset.IconsButtons.freeSwitchInactive.image
            }
        }.disposed(by: disposeBag)
    }
    
    
    private func resetUI() {
        titleLabel.text = nil
    }
    
    @IBAction func freeSwitchChanged(_ sender: Any) {
        delegate?.freeSwitchChanged(isOn: freeSwitch.isOn)
    }
    
    private func setAccessibilityIds() {
        set(accessibilityId:  .filterTextFieldIntCell)
        titleLabel.set(accessibilityId:  .filterFreeCellTitleLabel)
    }
}

