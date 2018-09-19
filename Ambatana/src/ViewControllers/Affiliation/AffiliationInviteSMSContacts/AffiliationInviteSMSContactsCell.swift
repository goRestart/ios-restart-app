import UIKit
import RxSwift

final class AffiliationInviteSMSContactsCell: UITableViewCell, ReusableCell {
    
    private enum Layout {
        static let titleLabelFontSize: CGFloat = 16.0
        static let subtitleLabelFontSize: CGFloat = 16.0
        static let defaultTitleTextColour: UIColor = .blackText
        static let defaultSubtitleTextColour: UIColor = .grayText
        static let checkboxSize: CGSize = CGSize(width: 18.0, height: 18.0)
        static let checkboxTrailingConstant: CGFloat = 28.0
        static let titleLabelTopConstant: CGFloat = 8.0
        static let subtitleLabelTopConstant: CGFloat = 8.0
        static let subtitleLabelBottonConstant: CGFloat = 8.0
        static let titleLabelTrailingConstant: CGFloat = 55.0
        static let titleLabelLeadingConstant: CGFloat = 55.0
        static let subtitleLabelTrailingConstant: CGFloat = 55.0
        static let subtitleLabelLeadingConstant: CGFloat = 55.0
        static let headerLetterLeadingConstant: CGFloat = 17.0
        static let headerLetterTrailingConstant: CGFloat = 8.0
        static let headerLetterTopConstant: CGFloat = 8.0
        static let headerLetterBottomConstant: CGFloat = 18.0
        static let headerLetterFontSize: CGFloat = 32.0
        static let headerLetterTextColour: UIColor = .blackText
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Layout.defaultTitleTextColour
        label.font = UIFont.systemFont(ofSize: Layout.titleLabelFontSize)
        label.textAlignment = .left
        return label
    }()
    
    private let headerLetter: UILabel = {
        let label = UILabel()
        label.textColor = Layout.headerLetterTextColour
        label.font = UIFont.systemFont(ofSize: Layout.headerLetterFontSize)
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Layout.defaultSubtitleTextColour
        label.font = UIFont.systemFont(ofSize: Layout.subtitleLabelFontSize)
        label.textAlignment = .left
        return label
    }()
    
    private let checkboxView: Checkbox = Checkbox()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupCheckbox()
        selectionStyle = .none
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setup(withViewModel viewModel: AffiliationInviteSMSContactsCellViewModel) {
        titleLabel.text = viewModel.name
        subtitleLabel.text = viewModel.phoneNumber
        headerLetter.text = viewModel.isFirstWithLetter ? viewModel.name.firstLetterNormalized.uppercased() : ""
        updateState(state: viewModel.state)
    }
    
    private func setupCheckbox() {
        checkboxView.isUserInteractionEnabled = false
    }
    
    
    func updateState(state: AffiliationInviteSMSContactsCellState) {
        updateCheckbox(withState: state)
        updateCellState(toState: state)
    }
    
    private func updateCellState(toState state: AffiliationInviteSMSContactsCellState) {
        isSelected = state == .selected
    }
    
    private func updateCheckbox(withState state: AffiliationInviteSMSContactsCellState) {
        checkboxView.isChecked = state == .selected
    }
    
    
    // MARK: Layout
    
    private func setupLayout() {
        contentView.addSubviewsForAutoLayout([titleLabel, subtitleLabel, headerLetter, checkboxView])
        
        let constraints = [checkboxView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                           checkboxView.widthAnchor.constraint(equalToConstant: Layout.checkboxSize.width),
                           checkboxView.heightAnchor.constraint(equalToConstant: Layout.checkboxSize.height),
                           checkboxView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.checkboxTrailingConstant),
                           titleLabel.leadingAnchor.constraint(equalTo:  contentView.leadingAnchor, constant: Layout.titleLabelLeadingConstant),
                           titleLabel.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor, constant: -Layout.titleLabelTrailingConstant),
                           subtitleLabel.leadingAnchor.constraint(equalTo:  contentView.leadingAnchor, constant: Layout.subtitleLabelLeadingConstant),
                           subtitleLabel.trailingAnchor.constraint(equalTo:  contentView.trailingAnchor, constant: -Layout.subtitleLabelTrailingConstant),
                           titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.titleLabelTopConstant),
                           subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Layout.subtitleLabelTopConstant),
                           subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.subtitleLabelBottonConstant),
                           headerLetter.leadingAnchor.constraint(equalTo:  contentView.leadingAnchor, constant: Layout.headerLetterLeadingConstant),
                           headerLetter.trailingAnchor.constraint(equalTo:  titleLabel.leadingAnchor, constant: -Layout.headerLetterTrailingConstant),
                           headerLetter.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.headerLetterTopConstant),
                           headerLetter.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.headerLetterBottomConstant)
            ]
        constraints.activate()
    }
}
