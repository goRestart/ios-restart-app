//
//  ModularNotificationCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ModularNotificationCellDelegate: class {
    func triggerModularNotificationDeeplink(deeplink: String, source: EventParameterNotificationClickArea, notificationCampaign: String?)
}


class ModularNotificationCell: UITableViewCell, ReusableCell {
    
    let background: UIView
    let heroImageView: UIImageView
    let textTitleLabel: UILabel
    let textBodyLabel: UILabel
    let callsToAction: [UIButton]
    let basicImage: UIImageView
    let iconImageView: UIImageView
    let thumbnails: [UIImageView]
    
    var campaignType: String?
    var heroImageHeightConstraint = NSLayoutConstraint()
    var basicImageWidthConstraint = NSLayoutConstraint()
    var basicImageHeightConstraint = NSLayoutConstraint()
    var firstThumbnailHeightConstraint = NSLayoutConstraint()
    var titleLabelTopMargin = NSLayoutConstraint()
    var textTitleLeftMargin = NSLayoutConstraint()
    var thumbnailsTopMarginConstraint = NSLayoutConstraint()
    var CTAHeightConstraints: [NSLayoutConstraint] = []
    
    fileprivate var basicImageIncluded: Bool = false
    
    var heroImageDeeplink: String? = nil
    var textTitleDeepLink: String? = nil
    var callsToActionDeeplinks: [String] = []
    var basicImageDeeplink: String? = nil
    var thumbnailsDeeplinks: [String] = []
    
    fileprivate var lastViewAdded: UIView? = nil
    
    weak var delegate: ModularNotificationCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.background = UIView()
        self.heroImageView = UIImageView()
        self.textTitleLabel = UILabel()
        self.textBodyLabel = UILabel()
        self.callsToAction = [UIButton(), UIButton(), UIButton()] // max 3 CTAs
        self.basicImage = UIImageView()
        self.iconImageView = UIImageView()
        self.thumbnails = [UIImageView() , UIImageView(), UIImageView(), UIImageView()] // max 4 thumbnails
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAccesibilityIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    func setupUI() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets(top: Metrics.shortMargin/2,
                                                 left: Metrics.shortMargin,
                                                 bottom: Metrics.shortMargin/2,
                                                 right: Metrics.shortMargin)
        
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [background, heroImageView, basicImage, iconImageView, textTitleLabel, textBodyLabel])
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: thumbnails)
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: callsToAction)
        
        // Config background view.
        background.backgroundColor = UIColor.white
        contentView.addSubview(background)
        background.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
        background.layout(with: contentView).top(to: .topMargin).left(to: .leftMargin).right(to: .rightMargin).bottom(to: .bottomMargin)
 
        // Config HeroImageView
        background.addSubview(heroImageView)
        heroImageView.layout(with: background).top().left().right()
        heroImageView.layout().height(0, constraintBlock: { [weak self] in self?.heroImageHeightConstraint = $0 })
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        
        let tapHeroImage = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        heroImageView.addGestureRecognizer(tapHeroImage)
        heroImageView.isUserInteractionEnabled = true
        
        // Config BasicImage
        background.addSubview(basicImage)
        basicImage.contentMode = .scaleAspectFill
        basicImage.clipsToBounds = true
        basicImage.layout(with: heroImageView).below(by: Metrics.margin)
        basicImage.layout(with: background).left(by: Metrics.margin)
        basicImage.layout().height(0, constraintBlock: { [weak self] in self?.basicImageHeightConstraint = $0 })
        basicImage.layout().width(0, constraintBlock: { [weak self] in self?.basicImageWidthConstraint = $0 })
        
        let tapBasicImage = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        basicImage.addGestureRecognizer(tapBasicImage)
        basicImage.isUserInteractionEnabled = true
        
        // Config title view:
        background.addSubview(textTitleLabel)
        textTitleLabel.layout(with: heroImageView).below(by: Metrics.margin,
                                                         constraintBlock: { [weak self] in self?.titleLabelTopMargin = $0 })
        textTitleLabel.layout(with: basicImage).left(to: .right, by: Metrics.shortMargin,
                                                     constraintBlock: { [weak self] in self?.textTitleLeftMargin = $0 })
        textTitleLabel.layout(with: background).right(by: -Metrics.margin)
        textTitleLabel.numberOfLines = 0
        textTitleLabel.font = UIFont.notificationTitleFont
        
        
        // Config text view:
        background.addSubview(textBodyLabel)
        textBodyLabel.layout(with: textTitleLabel).below(by: Metrics.modularNotificationTextMargin)
        textBodyLabel.layout(with: textTitleLabel).fillHorizontal()
        textBodyLabel.numberOfLines = 0
        textBodyLabel.font = UIFont.notificationSubtitleFont(read: false)
        
        let tapText = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        textBodyLabel.addGestureRecognizer(tapText)
        textBodyLabel.isUserInteractionEnabled = true
        
        // Config icon view:
        background.addSubview(iconImageView)
        iconImageView.layout().width(Metrics.modularNotificationIconImageSize).height(Metrics.modularNotificationIconImageSize)
        iconImageView.layout(with: basicImage).bottom(by: Metrics.modularNotificationIconImageOffset).right(by: Metrics.modularNotificationIconImageOffset)
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        
        // Config thumbnails
        background.addSubviews(thumbnails)
        let firstThumbnail = thumbnails.first
        firstThumbnail?.layout(with: textBodyLabel).below(by: Metrics.margin, constraintBlock: { [weak self] in self?.thumbnailsTopMarginConstraint = $0 })
        firstThumbnail?.layout(with: textBodyLabel).left()
        firstThumbnail?.layout().height(Metrics.modularNotificationThumbnailSize, constraintBlock: { [weak self] in self?.firstThumbnailHeightConstraint = $0 })
        firstThumbnail?.layout().widthProportionalToHeight()
        for (index, thumbnail) in thumbnails.enumerated() {
            thumbnail.contentMode = .scaleAspectFill
            thumbnail.clipsToBounds = true
            thumbnail.backgroundColor = UIColor.gray
            let tap = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped))
            thumbnail.addGestureRecognizer(tap)
            thumbnail.isUserInteractionEnabled = true
            thumbnail.isHidden = true
            if index > 0 {
                let previousThumbnail = thumbnails[index-1]
                thumbnail.layout(with: previousThumbnail).left(to: .right, by: Metrics.shortMargin).top()
                thumbnail.layout(with: previousThumbnail).proportionalHeight().proportionalWidth()
            }
        }
        
        // Config buttons
        background.addSubviews(callsToAction)
        let firstCTA = callsToAction.first
        
        firstCTA?.layout(with: firstThumbnail ?? textBodyLabel).below(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
        firstCTA?.layout(with: basicImage).below(by: Metrics.margin, relatedBy: .greaterThanOrEqual)
        firstCTA?.layout(with: background).left().right()
        
        for (index, button) in callsToAction.enumerated() {
            button.setTitleColor(UIColor.primaryColor , for: .normal)
            button.setBackgroundImage(UIColor.secondaryColorHighlighted.imageWithSize(CGSize(width: 1, height: 1)), for: .highlighted)
            button.titleLabel?.font = UIFont.mediumButtonFont
            addButtonSeparator(to: button)
            button.clipsToBounds = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(CTATapped))
            button.addGestureRecognizer(tap)
            button.isUserInteractionEnabled = true
            button.layout().height(0, constraintBlock: { [weak self] in self?.CTAHeightConstraints.append($0) })
            if index > 0 {
                let previousButton = callsToAction[index-1]
                button.layout(with: previousButton).below().fillHorizontal()
            }
        }
        callsToAction.last?.layout(with: background).bottom()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }
    
    
    //MARK: - Public Methods: 
    
    func addModularData(with modules: NotificationModular, isRead: Bool, notificationCampaign: String?) {
        
        campaignType = notificationCampaign
        //HeroImage if needed
        if let heroImage = modules.heroImage {
            addHeroImage(with: heroImage.imageURL, deeplink: heroImage.deeplink)
        } else {
            heroImageHeightConstraint.constant = 0
        }
        //BasicImage if needed
        if let basicImage = modules.basicImage {
            let shapeImage = basicImage.shape ?? .square
            addBasicImage(with: shapeImage, imageURL: basicImage.imageURL, deeplink: basicImage.deeplink)
            if let iconImage = modules.iconImage {
                addIconImage(with: iconImage.imageURL)
            }
        } else {
            basicImageIncluded = false
            basicImageWidthConstraint.constant = 0
            basicImageHeightConstraint.constant = 0
        }
        // Add text
        addTextInfo(with: modules.text.title, body: modules.text.body, deeplink: modules.text.deeplink, isRead: isRead)
        
        // thumbnails if needed
        if let thumbnailsModule = modules.thumbnails {
            firstThumbnailHeightConstraint.constant = Metrics.modularNotificationThumbnailSize
            thumbnailsTopMarginConstraint.constant = Metrics.shortMargin
            for (index, item) in thumbnailsModule.enumerated() {
                guard let deeplink = item.deeplink else { return } //only add thumbnail if there is deeplink
                addThumbnail(to: thumbnails[index], shape:item.shape ?? .square, imageURL: item.imageURL, deeplink: deeplink)
            }
        } else {
            firstThumbnailHeightConstraint.constant = 0
            thumbnailsTopMarginConstraint.constant = 0
        }
        
        // Call to action
        for (index, item) in modules.callToActions.enumerated() {
            CTAHeightConstraints[index].constant = Metrics.modularNotificationCTAHeight
            addCTA(to: callsToAction[index], title: item.title, deeplink: item.deeplink)
        }
    }
   
    
    // MARK: - Private methods
    
    fileprivate func addHeroImage(with imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        heroImageHeightConstraint.constant = Metrics.modularNotificationHeroImageHeight
        let placeholderImage = UIImage(named: "notificationHeroImagePlaceholder")
        heroImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage) {
            [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.heroImageView.image = image
            }
            
        }
        heroImageDeeplink = deeplink
        lastViewAdded = heroImageView
    }
    
    fileprivate func addBasicImage(with shape: NotificationImageShape, imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        basicImageIncluded = true
        basicImageHeightConstraint.constant = Metrics.modularNotificationBasicImageSize
        basicImageWidthConstraint.constant = Metrics.modularNotificationBasicImageSize
        var placeholderImage: UIImage?
        switch shape {
            case .square:
                placeholderImage = UIImage(named: "notificationBasicImageSquarePlaceholder")
                basicImage.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
            case .circle:
                placeholderImage = UIImage(named: "notificationBasicImageRoundPlaceholder")
                basicImage.layer.cornerRadius = Metrics.modularNotificationBasicImageSize/2
        }
        basicImage.lg_setImageWithURL(url, placeholderImage: placeholderImage) {
            [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.basicImage.image = image
            }
        }
        basicImageDeeplink = deeplink
    }
    
    fileprivate func addTextInfo(with title: String?, body: String, deeplink: String?, isRead: Bool) {
        if let title = title {
            titleLabelTopMargin.constant = Metrics.margin
            textTitleLabel.text = title
        } else {
            titleLabelTopMargin.constant = 0
        }
        textTitleLeftMargin.constant = basicImageIncluded ? Metrics.margin : 0
        textBodyLabel.font = UIFont.notificationSubtitleFont(read: isRead)
        if isRead {
            textBodyLabel.setHTMLFromString(htmlText: body)
        } else {
            textBodyLabel.text = body.ignoreHTMLTags
        }
        textTitleDeepLink = deeplink
        
        lastViewAdded = textBodyLabel
    }
    
    fileprivate func addIconImage(with imageURL: String) {
        guard let url = URL(string: imageURL) else { return }
        iconImageView.lg_setImageWithURL(url) {
            [weak self] (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                self?.iconImageView.image = image
            }
        }
    }
    
    fileprivate func addThumbnail(to thumbnailImageView: UIImageView, shape: NotificationImageShape, imageURL: String, deeplink: String) {
        guard let url = URL(string: imageURL) else { return }
        var placeholderImage: UIImage?
        switch shape {
            case .square:
                thumbnailImageView.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
                placeholderImage = UIImage(named: "notificationThumbnailSquarePlaceholder")
            case .circle:
                thumbnailImageView.layer.cornerRadius = Metrics.modularNotificationThumbnailSize/2
                placeholderImage = UIImage(named: "notificationThumbnailCirclePlaceholder")
            }
        thumbnailImageView.isHidden = false
        thumbnailImageView.lg_setImageWithURL(url, placeholderImage: placeholderImage)  {
            (result, urlResult) in
            if let image = result.value?.image, url == urlResult {
                thumbnailImageView.image = image
            }
        }
        thumbnailsDeeplinks.append(deeplink)
        lastViewAdded = thumbnailImageView
    }
    
    fileprivate func addCTA(to button: UIButton, title: String, deeplink: String) {
        button.setTitle(title, for: .normal)
        callsToActionDeeplinks.append(deeplink)
        lastViewAdded = button
    }
    
    fileprivate func addButtonSeparator(to button: UIButton) {
        let separator: UIView = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(separator)
        separator.layout(with: button).fillHorizontal()
        separator.layout(with: button).top().left().right()
        separator.backgroundColor = UIColor.grayLight
        button.bringSubview(toFront: separator)
        separator.layout().height(Metrics.modularNotificationCTASeparatorHeight)
    }
    
    private func resetUI() {
        heroImageView.image = nil
        basicImage.image = nil
        iconImageView.image = nil
        textTitleLabel.text = nil
        textBodyLabel.text = nil
        thumbnails.forEach {
            $0.image = nil
            $0.isHidden = true
        }
        CTAHeightConstraints.forEach { $0.constant = 0 }
        heroImageHeightConstraint.constant = 0
        basicImageWidthConstraint.constant = 0
        basicImageHeightConstraint.constant = 0
        firstThumbnailHeightConstraint.constant = 0
        titleLabelTopMargin.constant = 0
        textTitleLeftMargin.constant = 0
        thumbnailsTopMarginConstraint.constant = 0
        thumbnailsDeeplinks = []
        callsToActionDeeplinks = []
    }
    
    
    private func refreshState() {
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.alpha = highlighedState ? LGUIKitConstants.highlightedStateAlpha : 1.0
    }
    
    
    // MARK: - Deeplinks and actions on cell. 
    
    func elementTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        var sourceClickArea: EventParameterNotificationClickArea
        var deeplinkString: String? = nil
        switch view {
        case heroImageView:
            deeplinkString = heroImageDeeplink
            sourceClickArea = .heroImage
        case basicImage:
            deeplinkString = basicImageDeeplink
            sourceClickArea = .basicImage
        case textBodyLabel:
            deeplinkString = textTitleDeepLink
            sourceClickArea = .text
        default:
            sourceClickArea = .unknown
        }
        notifacionModuleTapped(with: deeplinkString, source: sourceClickArea)
    }
    
    func thumbnailTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIImageView else { return }
        guard let thumbnailTappedIndex = thumbnails.index(of: view) else { return }
        let sourceClickArea: EventParameterNotificationClickArea
        switch thumbnailTappedIndex {
        case 0:
            sourceClickArea = .thumbnail1
        case 1:
            sourceClickArea = .thumbnail2
        case 2:
            sourceClickArea = .thumbnail3
        case 3:
            sourceClickArea = .thumbnail4
        default:
            sourceClickArea = .unknown
        }
        notifacionModuleTapped(with: thumbnailsDeeplinks[thumbnailTappedIndex], source: sourceClickArea)
    }
    
    func CTATapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIButton else { return }
        guard let buttonTappedIndex = callsToAction.index(of: view) else { return }
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
        notifacionModuleTapped(with: callsToActionDeeplinks[buttonTappedIndex], source: sourceClickArea)
    }
    
    func notifacionModuleTapped(with deeplink: String?, source: EventParameterNotificationClickArea) {
        guard let deeplink = deeplink else { return }
        delegate?.triggerModularNotificationDeeplink(deeplink: deeplink, source: source,
                                                     notificationCampaign: campaignType)
    }
    
    // MARK: - Accesibility Ids.
    
    func setAccesibilityIds() {
        heroImageView.accessibilityId = .notificationsModularHeroImageView
        textBodyLabel.accessibilityId = .notificationsModularTextBodyLabel
        callsToAction.first?.accessibilityId = .notificationsModularCTA1
        if callsToAction.count > 1 {
            callsToAction[1].accessibilityId = .notificationsModularCTA2
        }
        if callsToAction.count > 2 {
            callsToAction[2].accessibilityId = .notificationsModularCTA3
        }
        basicImage.accessibilityId = .notificationsModularBasicImageView
        callsToAction.first?.accessibilityId = .notificationsModularThumbnailView1
        if callsToAction.count > 1 {
            thumbnails[1].accessibilityId = .notificationsModularThumbnailView2
        }
        if callsToAction.count > 2 {
            thumbnails[2].accessibilityId = .notificationsModularThumbnailView3
        }
        if callsToAction.count > 3 {
            thumbnails[3].accessibilityId = .notificationsModularThumbnailView4
        }
    }
}
