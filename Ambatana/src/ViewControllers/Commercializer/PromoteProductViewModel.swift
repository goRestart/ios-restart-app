//
//  PromoteProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum PromotionSource {
    case ProductSell
    case ProductDetail

    var hasPostPromotionActions: Bool {
        switch self {
        case .ProductSell:
            return true
        case .ProductDetail:
            return false
        }
    }
}

protocol PromoteProductViewModelDelegate: class {

    func viewModelDidRetrieveThemesListSuccessfully()
    func viewModelDidRetrieveThemesListWithError(errorMessage: String)

    func viewModelVideoDidSwitchFullscreen(isFullscreen: Bool)
    func viewModelVideoDidSwitchControlsVisible(controlsAreVisible: Bool)
    func viewModelVideoDidSwitchPlaying(isPlaying: Bool)
    func viewModelVideoDidSwitchAudio(videoIsMuted: Bool)

    func viewModelDidSelectThemeWithURL(themeURL: NSURL)

    func viewModelSentVideoForProcessing(processingViewModel: ProcessingVideoDialogViewModel)
}

public class PromoteProductViewModel: BaseViewModel {

    private let commercializerRepository: CommercializerRepository
    weak var delegate: PromoteProductViewModelDelegate?

    var promotionSource: PromotionSource
    var themes: [CommercializerTemplate]
    var themesCount: Int {
        return themes.count
    }
    var commercializerShownBefore: Bool {
        return UserDefaultsManager.sharedInstance.loadDidShowCommercializer()
    }
    var isFirstPlay: Bool = true
    var isFullscreen: Bool = false {
        didSet {
            delegate?.viewModelVideoDidSwitchFullscreen(isFullscreen)
        }
    }
    var isPlaying: Bool = true {
        didSet {
            delegate?.viewModelVideoDidSwitchPlaying(isPlaying)
        }
    }
    var controlsAreVisible: Bool = false {
        didSet {
            delegate?.viewModelVideoDidSwitchControlsVisible(controlsAreVisible)
        }
    }
    var videoIsMuted: Bool = true {
        didSet {
            delegate?.viewModelVideoDidSwitchAudio(videoIsMuted)
        }
    }
    var fullScreenButtonEnabled: Bool {
        return isFullscreen && isPlaying
    }
    var imageForAudioButton: UIImage {
        let imgName = videoIsMuted ? "ic_alert_yellow_white_inside" : "ic_alert_black"
        return UIImage(named: imgName) ?? UIImage()
    }
    var imageForPlayButton: UIImage {
        let imgName = isPlaying ? "ic_dollar_sold" : "ic_sold_white"
        return UIImage(named: imgName) ?? UIImage()
    }
    var autoHideControlsTimer: NSTimer?
    var autoHideControlsEnabled: Bool = true

    var statusVarStyleAtDisappear: UIStatusBarStyle {
        switch promotionSource {
        case .ProductSell:
            return .Default
        case .ProductDetail:
            return .LightContent
        }
    }

    // MARK: Lifecycle

    init?(commercializerRepository: CommercializerRepository, product: Product, promotionSource: PromotionSource) {
        self.commercializerRepository = commercializerRepository
        self.promotionSource = promotionSource
        let countryCode = product.postalAddress.countryCode ?? ""
        if let themes = commercializerRepository.templatesForCountryCode(countryCode) {
            self.themes = themes
        } else {
            self.themes = []
        }
        super.init()

        if themes.isEmpty { return nil }
    }

    convenience init?(product: Product, promotionSource: PromotionSource) {
        let commercializerRepository = Core.commercializerRepository
        self.init(commercializerRepository: commercializerRepository, product: product, promotionSource: promotionSource)
    }

    func commercializerIntroShown() {
        UserDefaultsManager.sharedInstance.saveDidShowCommercializer()
    }

    func switchFullscreen() {
        isFullscreen = !isFullscreen
    }

    func switchControlsVisible() {
        controlsAreVisible = !controlsAreVisible
        startAutoHidingControlsTimer()
    }

    dynamic func autoHideControls() {
        guard autoHideControlsEnabled else { return }
        switchControlsVisible()
    }

    func disableAutoHideControls() {
        autoHideControlsEnabled = false
    }

    func enableAutoHideControls() {
        autoHideControlsEnabled = true
        startAutoHidingControlsTimer()
    }

    func switchAudio() {
        videoIsMuted = !videoIsMuted
    }

    func switchIsPlaying() {
        isPlaying = !isPlaying
    }

    func titleForThemeAtIndex(index: Int) -> String? {
        guard index < themes.count else { return nil }
        return themes[index].title
    }

    func imageUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard index < themes.count else { return nil }
        guard let urlString = themes[index].thumbURL else { return nil }
        return NSURL(string: urlString)
    }

    func videoUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard index < themes.count else { return nil }
        guard let urlString = themes[index].videoURL else { return nil }
        return NSURL(string: urlString)
    }

    func selectThemeAtIndex(index: Int) {
        guard let url = videoUrlForThemeAtIndex(index) else { return }
        delegate?.viewModelDidSelectThemeWithURL(url)
    }

    func promoteVideo() {
        print("upload video to queue!!!")
        let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: promotionSource)
        delegate?.viewModelSentVideoForProcessing(processingViewModel)
    }


    // MARK: private methods

    private func startAutoHidingControlsTimer() {
        autoHideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "autoHideControls", userInfo: nil, repeats: false)
        if let autoHideControlsTimer = autoHideControlsTimer where !controlsAreVisible || !autoHideControlsEnabled {
            autoHideControlsTimer.invalidate()
        }
    }
}
