//
//  ModularNotificationCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ModularNotificationCellDelegate: class {
    func triggerModularNotificaionDeeplink(deeplink: String)
}


class ModularNotificationCell: UITableViewCell, ReusableCell {
    
    var background: UIView
    var heroImageView: UIImageView
    var textTitleLabel: UILabel
    var textBodyLabel: UILabel
    var callsToAction: [UIButton] = []
    var basicImage: UIImageView
    var iconImageView: UIImageView
    var thumbnails: [UIImageView] = []
    
    var heroImageDeeplink: String? = nil
    var textTitleDeepLink: String? = nil
    var callsToActionDeeplinks: [String] = []
    var basicImageDeeplink: String? = nil
    var thumbnailsDeeplinks: [String] = []
    
    fileprivate var lastViewAdded: UIView? = nil
    fileprivate var basicImageIncluded: Bool = false
    
    var primaryImageAction: (() -> Void)?
    
    weak var delegate: ModularNotificationCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.background = UIView()
        self.heroImageView = UIImageView()
        self.textTitleLabel = UILabel()
        self.textBodyLabel = UILabel()
        self.callsToAction = []
        self.basicImage = UIImageView()
        self.iconImageView = UIImageView()
        self.thumbnails = []
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heroImageView.setRoundedCorners([.topLeft, .topRight], cornerRadius: LGUIKitConstants.notificationCellCornerRadius)
        lastViewAdded?.setRoundedCorners([.bottomLeft, .bottomRight], cornerRadius: LGUIKitConstants.notificationCellCornerRadius)
    }
    
    func setupUI() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        contentView.preservesSuperviewLayoutMargins = false
        contentView.layoutMargins = UIEdgeInsets(top: Metrics.modularNotificationShortMargin,
                                                 left: Metrics.modularNotificationShortMargin,
                                                 bottom: Metrics.modularNotificationShortMargin,
                                                 right: Metrics.modularNotificationShortMargin)
        
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [background, heroImageView, basicImage, iconImageView, textTitleLabel, textBodyLabel])
        
        background.backgroundColor = UIColor.white
        contentView.addSubview(background)
        contentView.sendSubview(toBack: background)
        background.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
        
        background.layout(with: contentView).top(to: .topMargin).left(to: .leftMargin).right(to: .rightMargin).bottom(to: .bottomMargin)
 
        
        contentView.addSubview(heroImageView)
        heroImageView.layout(with: contentView).top(to: .topMargin).left(to: .leftMargin).right(to: .rightMargin)
        
        contentView.addSubview(basicImage)
        basicImage.contentMode = .scaleAspectFill
        
        contentView.addSubview(textTitleLabel)
        textTitleLabel.numberOfLines = 0
        textTitleLabel.font = UIFont.notificationTitleFont
        contentView.addSubview(textBodyLabel)
        textBodyLabel.numberOfLines = 0
        textBodyLabel.font = UIFont.notificationSubtitleFont(read: false)
        
        contentView.addSubview(iconImageView)
        iconImageView.rounded = true
        iconImageView.contentMode = .scaleAspectFit
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }
    
    
    // MARK: > Actions
    
    @IBAction func primaryImagePressed(_ sender: AnyObject) {
        primaryImageAction?()
    }
    
    
    //MARK: - Public Methods: 
    
    func addModularData(with modules: NotificationModular) {
        if let heroImage = modules.heroImage {
            addHeroImage(with: heroImage.imageURL, deeplink: heroImage.deeplink)
        }
        if let basicImage = modules.basicImage {
            basicImageIncluded = true
            let shapeImage = basicImage.shape ?? .square
            addBasicImage(with: shapeImage, imageURL: basicImage.imageURL, deeplink: basicImage.deeplink)
        }
        if let iconImage = modules.iconImage {
            addIconImage(with: iconImage.imageURL)
        }
        addTextInfo(with: modules.text.title, body: modules.text.body, deeplink: modules.text.deeplink)
        
        if let thumbnailsModule = modules.thumbnails {
            thumbnailsModule.forEach {
                guard let deeplink = $0.deeplink else { return } //only add thumbnail if there is deeplink
                addThumbnail(with: $0.shape ?? .square, imageURL: $0.imageURL, deeplink: deeplink)
            }
        }
        modules.callToActions.forEach { addCTA(with: $0.title, deeplink: $0.deeplink) }
        finishDrawer()
    }

    
    // MARK: - Private methods
    
    fileprivate func addHeroImage(with imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        heroImageView.lg_setImageWithURL(url)
        heroImageView.layout().height(Metrics.modularNotificationHeroImageHeight)
        let tap = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        heroImageView.addGestureRecognizer(tap)
        heroImageView.isUserInteractionEnabled = true
        
        heroImageDeeplink = deeplink
        
        lastViewAdded = heroImageView
    }
    
    fileprivate func addBasicImage(with shape: ImageShape, imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        basicImage.layout(with: heroImageView).below(by: Metrics.modularNotificationLongMargin)
        basicImage.layout(with: contentView).leftMargin(by: Metrics.modularNotificationLongMargin)
        basicImage.layout().width(Metrics.modularNotificationBasicImageSize).height(Metrics.modularNotificationBasicImageSize)
        basicImage.lg_setImageWithURL(url)
        switch shape {
            case .square:
                basicImage.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
            case .circle:
                basicImage.rounded = true
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        basicImage.addGestureRecognizer(tap)
        basicImage.isUserInteractionEnabled = true
        
        basicImageDeeplink = deeplink
    }
    
    fileprivate func addTextInfo(with title: String?, body: String, deeplink: String?) {
        textTitleLabel.layout(with: heroImageView).below(by: Metrics.modularNotificationLongMargin)
        if basicImageIncluded {
            textTitleLabel.layout(with: basicImage).left(to: .right, by: Metrics.modularNotificationShortMargin)
        } else {
            textTitleLabel.layout(with: contentView).leftMargin(by: Metrics.modularNotificationLongMargin)
        }
        textTitleLabel.layout(with: contentView).rightMargin(by: -Metrics.modularNotificationLongMargin)
        
        var marginToTop: CGFloat = 0
        if let title = title {
            textTitleLabel.text = title
            marginToTop = Metrics.modularNotificationTextMargin
        }
        textBodyLabel.layout(with: textTitleLabel).fillHorizontal().below(by: marginToTop)
        textBodyLabel.text = body
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        textBodyLabel.addGestureRecognizer(tap)
        textBodyLabel.isUserInteractionEnabled = true
        
        textTitleDeepLink = deeplink
        
        lastViewAdded = textBodyLabel
    }
    
    
    fileprivate func addIconImage(with imageURL: String) {
        guard basicImageIncluded else { return }
        guard let url = URL(string: imageURL) else { return }
        iconImageView.lg_setImageWithURL(url)
        iconImageView.layout().width(Metrics.modularNotificationIconImageSize).height(Metrics.modularNotificationIconImageSize)
        iconImageView.layout(with: basicImage).bottom(by: Metrics.modularNotificationIconImageOffset).right(by: Metrics.modularNotificationIconImageOffset)
    }
    
    fileprivate func addThumbnail(with shape: ImageShape, imageURL: String, deeplink: String) {
        guard let url = URL(string: imageURL) else { return }
        let thumbnailImage = UIImageView()
        thumbnailImage.lg_setImageWithURL(url)
        thumbnailImage.rounded = true
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImage.contentMode = .scaleAspectFit
        contentView.addSubview(thumbnailImage)
        thumbnailImage.layout().width(Metrics.modularNotificationThumbnailSize).height(Metrics.modularNotificationThumbnailSize)
        thumbnailImage.layout(with: textBodyLabel).below(by: Metrics.modularNotificationLongMargin)
        if thumbnails.isEmpty {
            thumbnailImage.layout(with: textBodyLabel).left()
        } else {
            thumbnailImage.layout(with: thumbnails.last).left(to: .right, by: Metrics.modularNotificationShortMargin)
        }
        thumbnails.append(thumbnailImage)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(thumbnailTapped))
        thumbnailImage.addGestureRecognizer(tap)
        thumbnailImage.isUserInteractionEnabled = true
        thumbnailsDeeplinks.append(deeplink)
        
        lastViewAdded = thumbnailImage
    }
    
    fileprivate func addCTA(with title: String, deeplink: String) {
        layoutIfNeeded()

        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        button.setStyle(.secondary(fontSize: .small, withBorder: false))
        button.setTitle(title, for: .normal)
        button.layout(with: contentView).fillHorizontal(by: Metrics.modularNotificationShortMargin)
        
        let marginToTop: CGFloat = callsToAction.isEmpty ? Metrics.modularNotificationLongMargin : 0
        if let lastViewAdded = lastViewAdded, basicImage.bottom < lastViewAdded.bottom {
            button.layout(with: lastViewAdded).below(by: marginToTop)
        } else {
            button.layout(with: basicImage).below(by: marginToTop)
        }
        button.layout().height(Metrics.modularNotificationCTAHeight)
        
        callsToAction.append(button)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(CTATapped))
        button.addGestureRecognizer(tap)
        button.isUserInteractionEnabled = true
        
        callsToActionDeeplinks.append(deeplink)
        
        lastViewAdded = button
        addButtonSeparator(to: button)
    }
    
    fileprivate func finishDrawer() {
        // Needed to link the last view added to the bottom of the content view.
        lastViewAdded?.layout(with: contentView).bottomMargin()
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
        heroImageView.layer.mask = nil
        basicImage.image = nil
        iconImageView.image = nil
        textTitleLabel.text = ""
        textBodyLabel.text = ""
        thumbnails.forEach { $0.removeFromSuperview()}
        thumbnails = []
        callsToAction.forEach { $0.removeFromSuperview()}
        callsToAction = []
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
        var deeplinkString: String? = nil
        switch view {
        case heroImageView:
            deeplinkString = heroImageDeeplink
        case basicImage:
            deeplinkString = basicImageDeeplink
        case textBodyLabel:
            deeplinkString = textTitleDeepLink
        default:
            break
        }
        notifacionModuleTapped(with: deeplinkString)
    }
    
    func thumbnailTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIImageView else { return }
        guard let thumbnailTappedIndex = thumbnails.index(of: view) else { return }
        notifacionModuleTapped(with: thumbnailsDeeplinks[thumbnailTappedIndex])
    }
    
    func CTATapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIButton else { return }
        guard let buttonTappedIndex = callsToAction.index(of: view) else { return }
        notifacionModuleTapped(with: callsToActionDeeplinks[buttonTappedIndex])
    }
    
    func notifacionModuleTapped(with deeplink: String?) {
        guard let deeplink = deeplink else { return }
        print(deeplink)
        delegate?.triggerModularNotificaionDeeplink(deeplink: deeplink)
    }
    
}
