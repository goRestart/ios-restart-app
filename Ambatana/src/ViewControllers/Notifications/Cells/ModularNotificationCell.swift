//
//  ModularNotificationCell.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit


class ModularNotificationCell: UITableViewCell, ReusableCell {
    
    var heroImageView: UIImageView
    var textTitleLabel: UILabel
    var textBodyLabel: UILabel
    var callsToAction: [UIButton]
    var basicImage: UIImageView
    var iconView: UIImageView
    var thumbnails: [UIImageView]
    
    var heroImageDeeplink: String? = nil
    var textTitleDeepLink: String? = nil
    var callsToActionDeeplinks: [String] = []
    var basicImageDeeplink: String? = nil
    var thumbnailsDeeplinks: [String] = []
    
    fileprivate var lastViewAdded: UIView? = nil
    fileprivate var basicImageIncluded: Bool = false
    
    var primaryImageAction: (() -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.heroImageView = UIImageView()
        self.textTitleLabel = UILabel()
        self.textBodyLabel = UILabel()
        self.callsToAction = []
        self.basicImage = UIImageView()
        self.iconView = UIImageView()
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
    
    func setupUI() {
        
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.white
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
        
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [heroImageView, basicImage, iconView, textTitleLabel, textBodyLabel])
        
        contentView.layout(with: self).top().left().right().bottom()
        contentView.addSubview(heroImageView)
        heroImageView.layout(with: contentView).top().left().right()
        
        contentView.addSubview(basicImage)
        basicImage.contentMode = .scaleAspectFill
        
        contentView.addSubview(textTitleLabel)
        textTitleLabel.numberOfLines = 0
        textTitleLabel.font = UIFont.notificationTitleFont
        contentView.addSubview(textBodyLabel)
        textBodyLabel.numberOfLines = 0
        textBodyLabel.font = UIFont.notificationSubtitleFont(read: false)
        
        contentView.addSubview(iconView)
        iconView.rounded = true
        iconView.contentMode = .scaleAspectFit
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }
    
    // MARK: > LayoutViews. 

    
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
        addTextInfo(with: modules.text.title, body: modules.text.body, deepLink: modules.text.deeplink)
        
        if let thumbnails = modules.thumbnails {
            thumbnails.forEach {
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
        lastViewAdded = heroImageView
        
    }
    
    fileprivate func addBasicImage(with shape: ImageShape, imageURL: String, deeplink: String?) {
        guard let url = URL(string: imageURL) else { return }
        basicImage.layout(with: heroImageView).below(by: Metrics.modularNotificationLongMargin)
        basicImage.layout(with: contentView).left(by: Metrics.modularNotificationLongMargin)
        basicImage.layout().width(Metrics.modularNotificationBasicImageSize).height(Metrics.modularNotificationBasicImageSize)
        basicImage.lg_setImageWithURL(url)
        basicImage.backgroundColor = UIColor.black
        switch shape {
            case .square:
                basicImage.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius
            case .circle:
                basicImage.rounded = true
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(elementTapped))
        basicImage.addGestureRecognizer(tap)
        basicImage.isUserInteractionEnabled = true
    }
    
    fileprivate func addTextInfo(with title: String?, body: String, deepLink: String?) {
        textTitleLabel.layout(with: heroImageView).below(by: Metrics.modularNotificationLongMargin)
        if basicImageIncluded {
            textTitleLabel.layout(with: basicImage).left(to: .right, by: Metrics.modularNotificationShortMargin)
        } else {
            textTitleLabel.layout(with: contentView).left(by: Metrics.modularNotificationShortMargin)
        }
        textTitleLabel.layout(with: contentView).right(by: -Metrics.modularNotificationLongMargin)
        
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
        
        lastViewAdded = textBodyLabel
    }
    
    
    fileprivate func addIconImage(with imageURL: String) {
        guard basicImageIncluded else { return }
        guard let url = URL(string: imageURL) else { return }
        iconView.backgroundColor = UIColor.blue
        iconView.lg_setImageWithURL(url)
        iconView.layout().width(Metrics.modularNotificationIconImageSize).height(Metrics.modularNotificationIconImageSize)
        iconView.layout(with: basicImage).bottom(by: Metrics.modularNotificationIconImageOffset).right(by: Metrics.modularNotificationIconImageOffset)
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
        button.layout(with: contentView).fillHorizontal()
        
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
        addButtonSeparator()
    }
    
    fileprivate func finishDrawer() {
        // Needed to link the last view added to the bottom of the content view.
        lastViewAdded?.layout(with: contentView).bottom(by: -Metrics.modularNotificationShortMargin)
    }
    
    fileprivate func addButtonSeparator() {
        let separator: UIView = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        separator.layout(with: contentView).fillHorizontal()
        separator.layout(with: lastViewAdded).above(by: 0)
        separator.backgroundColor = UIColor.grayLight
        separator.layout().height(Metrics.modularNotificationCTASeparatorHeight)
    }
    
    private func resetUI() {
        heroImageView.image = nil
        basicImage.image = nil
        iconView.image = nil
        textTitleLabel.text = ""
        textBodyLabel.text = ""
        thumbnails = []
        callsToAction = []
    }
    
    private func refreshState() {
        let highlighedState = self.isHighlighted || self.isSelected
        contentView.alpha = highlighedState ? LGUIKitConstants.highlightedStateAlpha : 1.0
    }
    
    // MARK: - Deeplinks and actions on cell. 
    
    func elementTapped(sender: UITapGestureRecognizer) {
        if let view = sender.view {
            switch view {
            case heroImageView:
                print("tap on hero image")
            case basicImage:
                print("basic image")
            case textBodyLabel:
                print("text body tap")
            default:
                break
            }
          // TODO: open deeplink with string...
        }
    }
    
    func thumbnailTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIImageView else { return }
        guard let thumbnailTappedIndex = thumbnails.index(of: view) else { return }
        print("thumbnail pressed: \(thumbnailTappedIndex)")
        print("deeplink is: \(thumbnailsDeeplinks[thumbnailTappedIndex])")
    }
    
    func CTATapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UIButton else { return }
        guard let buttonTappedIndex = callsToAction.index(of: view) else { return }
        print("call to action pressed: \(buttonTappedIndex)")
        print("deeplink is: \(callsToActionDeeplinks[buttonTappedIndex])")
    }
    
    
    
}
