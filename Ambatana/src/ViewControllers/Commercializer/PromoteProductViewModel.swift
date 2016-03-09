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

    func viewModelStartSendingVideoForProcessing()
    func viewModelSentVideoForProcessingSuccessfully(processingViewModel: ProcessingVideoDialogViewModel)
    func viewModelSentVideoForProcessingFailedWithMessage(message: String)
}

public class PromoteProductViewModel: BaseViewModel {

    private let commercializerRepository: CommercializerRepository
    weak var delegate: PromoteProductViewModelDelegate?

    var productId: String?
    var themeId: String?

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
            if let timer = autoHideControlsTimer where !controlsAreVisible {
                timer.invalidate()
            }
            delegate?.viewModelVideoDidSwitchControlsVisible(controlsAreVisible)
        }
    }

    var audioButtonIsVisible: Bool {
        return controlsAreVisible || isFirstPlay
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
        let imgName = videoIsMuted ? "ic_sound_off" : "ic_sound_on"
        return UIImage(named: imgName) ?? UIImage()
    }
    var imageForPlayButton: UIImage {
        let imgName = isPlaying ? "ic_pause_video" : "ic_play_video"
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
        self.themes = commercializerRepository.templatesForCountryCode(countryCode) ?? []
        self.productId = product.objectId
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

    func idForThemeAtIndex(index: Int) -> String? {
        guard 0...themes.count-1 ~= index else { return nil }
        return themes[index].objectId
    }

    func titleForThemeAtIndex(index: Int) -> String? {
        guard 0...themes.count-1 ~= index else { return nil }
        return themes[index].title
    }

    func imageUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard 0...themes.count-1 ~= index else { return nil }
        guard let urlString = themes[index].thumbURL else { return nil }
        return NSURL(string: urlString)
    }

    func videoUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard 0...themes.count-1 ~= index else { return nil }
        guard let urlString = themes[index].videoURL else { return nil }
        return NSURL(string: urlString)
    }

    func selectThemeAtIndex(index: Int) {
        guard let url = videoUrlForThemeAtIndex(index) else { return }
        delegate?.viewModelDidSelectThemeWithURL(url)
        guard let selectedThemeId = idForThemeAtIndex(index) else { return }
        themeId = selectedThemeId
    }

    func promoteVideo() {
        delegate?.viewModelStartSendingVideoForProcessing()
        guard let productId = productId, themeId = themeId else {
            // TODO : Handle error propperly
            delegate?.viewModelSentVideoForProcessingFailedWithMessage("_ Internal: no product id or theme id")
            return
        }
        commercializerRepository.create(productId, templateId: themeId) { [weak self] result in
            if let strongSelf = self {
                if let _ = result.value {
                    let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: strongSelf.promotionSource)
                    strongSelf.delegate?.viewModelSentVideoForProcessingSuccessfully(processingViewModel)
                } else if let error = result.error {
                    // TODO : Handle error propperly
                    var errorMessage: String = ""
                    switch error {
                    case .Network:
                        errorMessage = "_ Network error"
                    case .Internal:
                        errorMessage = "_ Internal error"
                    default:
                        errorMessage = " _ Other error"
                    }
                    strongSelf.delegate?.viewModelSentVideoForProcessingFailedWithMessage(errorMessage)
                }
            }
        }
    }


    // MARK: private methods

    private func startAutoHidingControlsTimer() {
        autoHideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "autoHideControls", userInfo: nil, repeats: false)
        if let autoHideControlsTimer = autoHideControlsTimer where !controlsAreVisible || !autoHideControlsEnabled {
            autoHideControlsTimer.invalidate()
        }
    }
}
