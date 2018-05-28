import UIKit
import LGComponents

class SettingsLogoutCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var logoutButton: LetgoButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        logoutButton.isHighlighted = highlighted
    }

    private func setupUI() {
        logoutButton.isUserInteractionEnabled = false
        logoutButton.setStyle(.logout)
        logoutButton.cornerRadius = 22
        logoutButton.setTitle(R.Strings.settingsLogoutButton, for: .normal)
    }
}
