import UIKit
import LGCoreKit
import LGComponents

class BlockedUserCell: UITableViewCell, ReusableCell {

    static let defaultHeight: CGFloat = 76

    private struct Layout {
        static let avatarSize: CGFloat = 60.0
        static let nameLeadingMargin: CGFloat = 12.0
    }
    
    var avatarImageView: UIImageView = {
        let imageView = UIImageView(image: R.Asset.IconsButtons.userPlaceholder.image)
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bigBodyFontLight
        label.textColor = UIColor.blackText
        return label
    }()
    

    var lines: [CALayer] = []
    
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
        setAccessibilityIds()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected && !isEditing) {
            setSelected(false, animated: animated)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.setRoundedCorners()
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }

    func setupCellWithUser(_ user: User, indexPath: IndexPath) {
        let tag = (indexPath as NSIndexPath).hash
        userNameLabel.text = user.name
        
        let placeholder = LetgoAvatar.avatarWithID(user.objectId, name: user.name)
        avatarImageView.image = placeholder
        if let avatarURL = user.avatar?.fileURL {
            avatarImageView.lg_setImageWithURL(avatarURL, placeholderImage: placeholder) {
                [weak self] (result, url) in
                if let image = result.value?.image, self?.tag == tag {
                    self?.avatarImageView.image = image
                }
            }
        }
    }

    // MARK: - Private methods
    
    private func setupConstraints() {
        addSubviewsForAutoLayout([avatarImageView, userNameLabel])
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.margin),
            avatarImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Layout.avatarSize),
            
            userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Layout.nameLeadingMargin),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
    }

    private func resetUI() {
        avatarImageView.image = R.Asset.IconsButtons.userPlaceholder.image
        userNameLabel.text = ""
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = UIColor.primaryColor
    }
}

extension BlockedUserCell {
    func setAccessibilityIds() {
        avatarImageView.set(accessibilityId: .blockedUserCellAvatarImageView)
        userNameLabel.set(accessibilityId: .blockedUserCellUserNameLabel)
    }
}
