import LGCoreKit
import LGComponents

protocol NotificationCenterModularCellDelegate: class {
    func triggerModularNotification(deeplink: String, source: EventParameterNotificationClickArea, notificationCampaign: String?)
}

enum NotificationCenterCellDate {
    case minutesAgo(minutes: Int)
    case hoursAgo(hours: Int)
    case daysAgo(days: Int)
    case weeksAgo(weeks: Int)
    
    var title: String {
        switch self {
        case .minutesAgo(let mins):
            return R.Strings.notificationsCellDateMinsAgo(mins)
        case .hoursAgo(let hours):
            return R.Strings.notificationsCellDateHoursAgo(hours)
        case .daysAgo(let days):
            return R.Strings.notificationsCellDateDaysAgo(days)
        case .weeksAgo(let weeks):
            return R.Strings.notificationsCellDateWeeksAgo(weeks)
        }
    }
}

final class NotificationCenterModularCell: UITableViewCell, ReusableCell, UICollectionViewDataSource, UICollectionViewDelegate {

    private struct Layout {
        static let cellTopMargin: CGFloat = 24
        static let horizontalMargin: CGFloat = 12
        static let basicImageSize: CGFloat = 46
        static let iconImageSize: CGFloat = 16
        static let thumbnailSize: CGFloat = 68
        static let ctaButtonHeight: CGFloat = 34
        static let thumbnailsCollectionViewTopMargin: CGFloat = 8
        static let thumbnailsCollectionViewHeight: CGFloat = 72
    }
    
    private let heroImageView: UIImageView = {
        let heroImageView = UIImageView()
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.isUserInteractionEnabled = true
        return heroImageView
    }()
    
    private let basicImageView: UIImageView = {
        let basicImageView = UIImageView()
        basicImageView.contentMode = .scaleAspectFill
        basicImageView.clipsToBounds = true
        basicImageView.isUserInteractionEnabled = true
        return basicImageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemBoldFont(size: 18)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    private let bodyLabel: UILabel = {
        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemRegularFont(size: 16)
        bodyLabel.numberOfLines = 0
        bodyLabel.isUserInteractionEnabled = true
        return bodyLabel
    }()
    
    private let iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        return iconImageView
    }()

    private let thumbnailsCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.itemSize = NotificationCenterThumbnailCell.cellSize()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        let thumbnailsCollectionView = UICollectionView(frame: .zero,
                                                         collectionViewLayout: layout)
        thumbnailsCollectionView.showsHorizontalScrollIndicator = false
        thumbnailsCollectionView.backgroundColor = .white
        return thumbnailsCollectionView
    }()
    
    // Max 3 CTA buttons
    private var ctaButtons: [LetgoButton] = [
        LetgoButton(withStyle: .primary(fontSize: .verySmallBold)),
        LetgoButton(withStyle: .secondary(fontSize: .verySmallBold, withBorder: true)),
        LetgoButton(withStyle: .secondary(fontSize: .verySmallBold, withBorder: true))]
    
    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = UIFont.systemRegularFont(size: 12)
        dateLabel.textColor = .grayDisclaimerText
        dateLabel.sizeToFit()
        return dateLabel
    }()
    
    private let separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.veryLightGray
        return separator
    }()
    
    private var campaignType: String?
    private var heroImageHeightConstraint: NSLayoutConstraint?
    private var basicImageWidthConstraint: NSLayoutConstraint?
    private var basicImageHeightConstraint: NSLayoutConstraint?
    private var thumbnailsCollectionViewHeightConstraint: NSLayoutConstraint?
    private var titleLabelTopMargin: NSLayoutConstraint?
    private var titleLabelLeftMargin: NSLayoutConstraint?
    private var bodyLabelTopMargin: NSLayoutConstraint?
    private var ctaButtonsHeightConstraints: [NSLayoutConstraint] = []
    
    private var basicImageIncluded: Bool = false
    
    private var heroImageDeeplink: String? = nil
    private var textTitleDeepLink: String? = nil
    private var callsToActionDeeplinks: [String] = []
    private var basicImageDeeplink: String? = nil
    
    weak var delegate: NotificationCenterModularCellDelegate?
    
    private var thumbnails: [NotificationImageModule] = []
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        thumbnailsCollectionView.dataSource = self
        thumbnailsCollectionView.delegate = self
        thumbnailsCollectionView.register(NotificationCenterThumbnailCell.self,
                                          forCellWithReuseIdentifier: NotificationCenterThumbnailCell.reusableID)
        setupLayout()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    private func resetUI() {
        heroImageView.image = nil
        basicImageView.image = nil
        iconImageView.image = nil
        titleLabel.text = ""
        bodyLabel.text = ""
        ctaButtonsHeightConstraints.forEach { $0.constant = 0 }
        heroImageHeightConstraint?.constant = 0
        basicImageWidthConstraint?.constant = 0
        basicImageHeightConstraint?.constant = 0
        thumbnailsCollectionViewHeightConstraint?.constant = 0
        titleLabelTopMargin?.constant = 0
        titleLabelLeftMargin?.constant = 0
        callsToActionDeeplinks = []
        thumbnails = []
    }
    
    
    // MARK: - UI
    
    func setupUI() {
        selectionStyle = .none
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets(top: Metrics.shortMargin/2,
                                                 left: Metrics.shortMargin,
                                                 bottom: Metrics.shortMargin/2,
                                                 right: Metrics.shortMargin)
        
        let tapHeroImage = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        heroImageView.addGestureRecognizer(tapHeroImage)
        let tapBasicImage = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        basicImageView.addGestureRecognizer(tapBasicImage)
        let tapText = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        bodyLabel.addGestureRecognizer(tapText)
        
        setupButtons()
    }
    
    private func setupLayout() {
        contentView.addSubviewsForAutoLayout([heroImageView, basicImageView, titleLabel, bodyLabel, iconImageView, dateLabel, thumbnailsCollectionView, separator])
        contentView.addSubviewsForAutoLayout(ctaButtons)

        let heroImageHeightDefaultConstraint = heroImageView.heightAnchor.constraint(equalToConstant: 0)
        let basicImageHeightDefaultConstraint = basicImageView.heightAnchor.constraint(equalToConstant: 0)
        let basicImageWidthDefaultConstraint = basicImageView.widthAnchor.constraint(equalToConstant: 0)
        let titleLabelDefaultTopMargin = titleLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: Layout.cellTopMargin)
        let titleLabelDefaultLeftMargin = titleLabel.leftAnchor.constraint(equalTo: basicImageView.rightAnchor,
                                                                    constant: Layout.horizontalMargin)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        let bodyLabelDefaultTopMargin = bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        bodyLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        bodyLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        dateLabel.setContentHuggingPriority(.required, for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let thumbnailsCollectionViewHeightDefaultConstraint = thumbnailsCollectionView.heightAnchor.constraint(equalToConstant: 0)
        
        let constraints = [
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            heroImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            heroImageHeightDefaultConstraint,
            
            basicImageView.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: Layout.cellTopMargin),
            basicImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Layout.horizontalMargin),
            basicImageHeightDefaultConstraint,
            basicImageWidthDefaultConstraint,
            
            titleLabelDefaultTopMargin,
            titleLabelDefaultLeftMargin,
            titleLabel.rightAnchor.constraint(equalTo: iconImageView.leftAnchor, constant: -Layout.horizontalMargin),
            
            dateLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: Layout.cellTopMargin),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Layout.horizontalMargin),
            
            bodyLabelDefaultTopMargin,
            bodyLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            bodyLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            
            iconImageView.widthAnchor.constraint(equalTo: dateLabel.widthAnchor),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
            iconImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            iconImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Layout.horizontalMargin),
            
            thumbnailsCollectionView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: Layout.thumbnailsCollectionViewTopMargin),
            thumbnailsCollectionView.leftAnchor.constraint(equalTo: basicImageView.rightAnchor, constant: Layout.horizontalMargin),
            thumbnailsCollectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Layout.horizontalMargin),
            thumbnailsCollectionViewHeightDefaultConstraint,
            
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.horizontalMargin),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.horizontalMargin),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ]
        NSLayoutConstraint.activate(constraints)

        heroImageHeightConstraint = heroImageHeightDefaultConstraint
        basicImageHeightConstraint = basicImageHeightDefaultConstraint
        basicImageWidthConstraint = basicImageWidthDefaultConstraint
        titleLabelTopMargin = titleLabelDefaultTopMargin
        titleLabelLeftMargin = titleLabelDefaultLeftMargin
        bodyLabelTopMargin = bodyLabelDefaultTopMargin
        thumbnailsCollectionViewHeightConstraint = thumbnailsCollectionViewHeightDefaultConstraint
    }
    
    private func setupButtons() {
        for (index, button) in ctaButtons.enumerated() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(ctaTapped))
            button.addGestureRecognizer(tap)

            contentView.addSubviewForAutoLayout(button)
            var constraints: [NSLayoutConstraint] = []
            let leftConstraint = button.leftAnchor.constraint(equalTo: basicImageView.rightAnchor, constant: Layout.horizontalMargin)
            let heightConstraint = button.heightAnchor.constraint(equalToConstant: 0)
            ctaButtonsHeightConstraints.append(heightConstraint)
            constraints.append(contentsOf: [leftConstraint, heightConstraint])
            
            let isFirstButton = index == 0
            if isFirstButton {
                constraints.append(
                    contentsOf: [button.topAnchor.constraint(greaterThanOrEqualTo: thumbnailsCollectionView.bottomAnchor,
                                                             constant: Metrics.margin)])
            } else if let previousButton = ctaButtons[safeAt: index-1] {
                constraints.append(button.topAnchor.constraint(equalTo: previousButton.bottomAnchor, constant: Metrics.margin))
            }
            let isLastButton = index == ctaButtons.count-1
            if isLastButton {
                constraints.append(button.bottomAnchor.constraint(equalTo: separator.topAnchor))
            }
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    
    // MARK: - Modular data
    
    func addModularData(with modules: NotificationModular, isRead: Bool, notificationCampaign: String?, date: Date) {
        let notificationCellDate: NotificationCenterCellDate = date.notificationCellDate()
        dateLabel.text = notificationCellDate.title
        
        campaignType = notificationCampaign

        if let heroImage = modules.heroImage {
            addHeroImage(with: heroImage.imageURL, deeplink: heroImage.deeplink)
        } else {
            heroImageHeightConstraint?.constant = 0
        }

        if let basicImage = modules.basicImage {
            let shapeImage = basicImage.shape ?? .square
            addBasicImage(with: shapeImage, imageURL: basicImage.imageURL, deeplink: basicImage.deeplink)
            if let iconImage = modules.iconImage {
                addIconImage(with: iconImage.imageURL)
            }
        } else {
            basicImageIncluded = false
            basicImageWidthConstraint?.constant = 0
            basicImageHeightConstraint?.constant = 0
        }
        
        addTextInfo(with: modules.text.title, body: modules.text.body, deeplink: modules.text.deeplink, isRead: isRead)
        
        
        if let thumbnailsModule = modules.thumbnails {
            thumbnails.append(contentsOf: thumbnailsModule.filter { $0.deeplink != nil })
            if thumbnails.count > 0 {
                thumbnailsCollectionViewHeightConstraint?.constant = Layout.thumbnailsCollectionViewHeight
                thumbnailsCollectionView.reloadData()
            }
        } else {
            thumbnailsCollectionViewHeightConstraint?.constant = 0
        }
        
        for (index, item) in modules.callToActions.enumerated() {
            ctaButtonsHeightConstraints[index].constant = Layout.ctaButtonHeight
            addCTA(to: ctaButtons[index], title: item.title, deeplink: item.deeplink)
        }
    }
    
    private func addHeroImage(with imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        heroImageHeightConstraint?.constant = Metrics.modularNotificationHeroImageHeight
        let placeholderImage = R.Asset.BackgroundsAndImages.notificationHeroImagePlaceholder.image
        heroImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage) {
            [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.heroImageView.image = image
            }
        }
        heroImageDeeplink = deeplink
    }
    
    private func addBasicImage(with shape: NotificationImageShape, imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        basicImageIncluded = true
        basicImageHeightConstraint?.constant = Layout.basicImageSize
        basicImageWidthConstraint?.constant = Layout.basicImageSize
        var placeholderImage: UIImage?
        switch shape {
        case .square:
            placeholderImage = R.Asset.BackgroundsAndImages.notificationBasicImageSquarePlaceholder.image
            basicImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        case .circle:
            placeholderImage = R.Asset.BackgroundsAndImages.notificationBasicImageRoundPlaceholder.image
            basicImageView.cornerRadius = Layout.basicImageSize/2
        }
        basicImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage) {
            [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.basicImageView.image = image
            }
        }
        basicImageDeeplink = deeplink
    }
    
    private func addTextInfo(with title: String?, body: String, deeplink: String?, isRead: Bool) {
        if let title = title {
            titleLabelTopMargin?.constant = Layout.cellTopMargin
            titleLabel.text = title
            bodyLabelTopMargin?.constant = Metrics.veryShortMargin
        } else {
            titleLabelTopMargin?.constant = 0
            bodyLabelTopMargin?.constant = Metrics.margin
        }
        titleLabelLeftMargin?.constant = basicImageIncluded ? Metrics.margin : 0
        bodyLabel.font = UIFont.notificationSubtitleFont(read: isRead)
        if isRead {
            bodyLabel.setHTMLFromString(htmlText: body)
        } else {
            bodyLabel.text = body.ignoreHTMLTags
        }
        textTitleDeepLink = deeplink
    }
    
    private func addIconImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        iconImageView.lg_setImageWithURL(url) {
            [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.iconImageView.image = image
            }
        }
    }
    
    private func addCTA(to button: UIButton, title: String, deeplink: String) {
        button.setTitle(title, for: .normal)
        callsToActionDeeplinks.append(deeplink)
    }
    
    
    // MARK: - UI Actions
    
    @objc func elementTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        var sourceClickArea: EventParameterNotificationClickArea
        var deeplinkString: String? = nil
        switch view {
        case heroImageView:
            deeplinkString = heroImageDeeplink
            sourceClickArea = .heroImage
        case basicImageView:
            deeplinkString = basicImageDeeplink
            sourceClickArea = .basicImage
        case bodyLabel:
            deeplinkString = textTitleDeepLink
            sourceClickArea = .text
        default:
            sourceClickArea = .unknown
        }
        notificationCardTapped(with: deeplinkString, source: sourceClickArea)
    }
    
    @objc func ctaTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? LetgoButton else { return }
        guard let buttonTappedIndex = ctaButtons.index(of: view) else { return }
        let sourceClickArea: EventParameterNotificationClickArea
        switch buttonTappedIndex {
        case 0:
            sourceClickArea = .cta1
        case 1:
            sourceClickArea = .cta2
        case 2:
            sourceClickArea = .cta3
        default:
            sourceClickArea = .unknown
        }
        notificationCardTapped(with: callsToActionDeeplinks[buttonTappedIndex], source: sourceClickArea)
    }
    
    func notificationCardTapped(with deeplink: String?, source: EventParameterNotificationClickArea) {
        guard let deeplink = deeplink else { return }
        delegate?.triggerModularNotification(deeplink: deeplink,
                                             source: source,
                                             notificationCampaign: campaignType)
    }
    
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = thumbnailsCollectionView.dequeue(type: NotificationCenterThumbnailCell.self,
                                                          for: indexPath)  else { return UICollectionViewCell() }
        guard let thumbnail = thumbnails[safeAt: indexPath.row] else { return UICollectionViewCell() }
        let imageUrlString = thumbnail.imageURL
        let shape = thumbnail.shape
        let deeplink = thumbnail.deeplink
        cell.setup(imageUrlString: imageUrlString, shape: shape ?? .square, deeplink: deeplink)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let deeplink = thumbnails[safeAt: indexPath.row]?.deeplink else { return }
        let sourceClickArea: EventParameterNotificationClickArea = .thumbnail(index: indexPath.row)
        notificationCardTapped(with: deeplink, source: sourceClickArea)
    }
    
    
    // MARK: - Accessibility
    
    func setAccesibilityIds() {
        heroImageView.set(accessibilityId: .notificationsModularHeroImageView)
        titleLabel.set(accessibilityId: .notificationsModularTextTitleLabel)
        bodyLabel.set(accessibilityId: .notificationsModularTextBodyLabel)
        basicImageView.set(accessibilityId: .notificationsModularBasicImageView)
        iconImageView.set(accessibilityId: .notificationsModularIconImageView)
        thumbnailsCollectionView.set(accessibilityId: .notificationsModularThumbnailCollectionView)
        ctaButtons.first?.set(accessibilityId: .notificationsModularCTA1)
        ctaButtons[safeAt: 1]?.set(accessibilityId: .notificationsModularCTA2)
        ctaButtons[safeAt: 2]?.set(accessibilityId: .notificationsModularCTA3)
    }
}

fileprivate extension Date {
    func notificationCellDate() -> NotificationCenterCellDate {
        let calendar = NSCalendar.current
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: self)
        let minutes = calendar.dateComponents([.minute], from: startOfNow, to: startOfTimeStamp).minute
        let hours = calendar.dateComponents([.hour], from: startOfNow, to: startOfTimeStamp).hour
        let days = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp).day
        let weeks = calendar.dateComponents([.weekOfMonth], from: startOfNow, to: startOfTimeStamp).weekOfMonth
        
        switch (minutes, hours, days, weeks) {
        case (.some(let minutes), _, _, _) where abs(minutes) < DateDescriptor.maximumMinutesInAHour:
            return .minutesAgo(minutes: abs(minutes))
        case (_, .some(let hours), _, _) where abs(hours) < DateDescriptor.maximumHoursInADay:
            return .hoursAgo(hours: abs(hours))
        case (_, _, .some(let days), _) where abs(days) < DateDescriptor.maximumDaysInAMonth:
            return .daysAgo(days: abs(days))
        case (_, _, _, .some(let weeks)):
            return .weeksAgo(weeks: abs(weeks))
        default:
            return .minutesAgo(minutes: 0)
        }
    }
}
