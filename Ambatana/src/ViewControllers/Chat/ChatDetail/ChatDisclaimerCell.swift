import UIKit
import RxSwift
import LGComponents

class ChatDisclaimerCell: UITableViewCell, ReusableCell {
    
    @IBOutlet weak var backgroundCellView: UIView!

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: LetgoButton!
    
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate static let backgroundWithOutImageTop: CGFloat = -4
    fileprivate static let backgroundWithImageTop: CGFloat = 25
    fileprivate static let titleVisibleTop: CGFloat = 67
    fileprivate static let titleInvisibleTop: CGFloat = 8
    fileprivate static let buttonVisibleHeight: CGFloat = 30
    fileprivate static let buttonVisibleBottom: CGFloat = 8
    fileprivate static let buttonHContentInset: CGFloat = 16

    fileprivate var buttonAction: (() -> Void)?
    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupRxBindings()
        setAccessibilityIds()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.setStyle(.primary(fontSize: .small))
    }
}


// MARK: - Public methods

extension ChatDisclaimerCell {
    func showAvatar(_ show: Bool) {
        hideImageAndTitle(!show)
    }

    func setMessage(_ message: NSAttributedString) {
        messageLabel.attributedText = message
    }

    func setButton(title: String?) {
        button.setTitle(title, for: .normal)
        hideButton(title == nil || button.isHidden)
    }

    func setButton(action: (() -> Void)?) {
        buttonAction = action
        hideButton(action == nil || button.isHidden)
    }
}


// MARK: - Private methods

fileprivate extension ChatDisclaimerCell {
    func setupUI() {
        backgroundCellView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        backgroundCellView.backgroundColor = UIColor.disclaimerColor
        backgroundCellView.layer.borderWidth = 1
        backgroundCellView.layer.borderColor = UIColor.white.cgColor

        messageLabel.textColor = UIColor.darkGrayText
        messageLabel.font = UIFont.bigBodyFont
        button.setStyle(.primary(fontSize: .small))
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: ChatDisclaimerCell.buttonHContentInset,
                                                bottom: 0, right: ChatDisclaimerCell.buttonHContentInset)

        backgroundColor = .clear
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        setupRAssets()
    }

    private func setupRAssets() {
        avatarImageView.image = R.Asset.BackgroundsAndImages.imgCallCenterGirl.image
    }

    func setupRxBindings() {
        button.rx.tap.asObservable().subscribeNext { [weak self] in
            self?.buttonAction?()
        }.disposed(by: disposeBag)
    }
    
    @objc func tapped() {
        buttonAction?()
    }

    func hideImageAndTitle(_ hide: Bool) {
        backgroundTopConstraint?.constant = hide ? ChatDisclaimerCell.backgroundWithOutImageTop : ChatDisclaimerCell.backgroundWithImageTop
        titleTopConstraint?.constant = hide ? ChatDisclaimerCell.titleInvisibleTop : ChatDisclaimerCell.titleVisibleTop
        avatarImageView.isHidden = hide
        titleLabel.text = hide ? nil : R.Strings.chatDisclaimerLetgoTeam
    }
    
    func hideButton(_ hide: Bool) {
        buttonHeightConstraint?.constant = hide ? 0 : ChatDisclaimerCell.buttonVisibleHeight
        buttonBottomConstraint?.constant = hide ? 0 : ChatDisclaimerCell.buttonVisibleBottom
        button.isHidden = hide
    }
}

extension ChatDisclaimerCell {
    func setAccessibilityIds() {
        set(accessibilityId: .chatDisclaimerCellContainer)
        messageLabel.set(accessibilityId: .chatDisclaimerCellMessageLabel)
        button.set(accessibilityId: .chatDisclaimerCellButton)
    }
}
