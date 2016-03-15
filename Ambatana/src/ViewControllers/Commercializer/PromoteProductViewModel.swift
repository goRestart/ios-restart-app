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

public enum VideoPlayerViewStatus {
    case VideoReady
    case VideoFailed
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
    func viewModelSentVideoForProcessing(processingViewModel: ProcessingVideoDialogViewModel, status: VideoProcessStatus)

    func viewModelVideoPlayerStatusChanged(status: VideoPlayerViewStatus)
}

public class PromoteProductViewModel: BaseViewModel {

    private let commercializerRepository: CommercializerRepository
    weak var delegate: PromoteProductViewModelDelegate?

    var productId: String?
    var themeId: String?

    var selectedIndex: Int = 0

    var promotionSource: PromotionSource
    var videoPlayerViewStatus: VideoPlayerViewStatus = .VideoReady {
        didSet {
            delegate?.viewModelVideoPlayerStatusChanged(videoPlayerViewStatus)
        }
    }
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
            startAutoHidingControlsTimer()
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

    var statusBarStyleAtDisappear: UIStatusBarStyle {
        switch promotionSource {
        case .ProductSell:
            return .Default
        case .ProductDetail:
            return .LightContent
        }
    }

    
    // MARK: Lifecycle

    init?(commercializerRepository: CommercializerRepository, product: Product, themes: [CommercializerTemplate], promotionSource: PromotionSource) {
        self.commercializerRepository = commercializerRepository
        self.promotionSource = promotionSource
        self.themes = themes
        self.productId = product.objectId
        super.init()

        guard let _ = productId else { return nil }
        if themes.isEmpty { return nil }
    }

    convenience init?(product: Product, themes: [CommercializerTemplate], promotionSource: PromotionSource) {
        let commercializerRepository = Core.commercializerRepository
        self.init(commercializerRepository: commercializerRepository, product: product, themes: themes, promotionSource: promotionSource)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        controlsAreVisible = !isFirstPlay
    }

    override func didBecomeInactive() {
        super.didBecomeInactive()
        if let timer = autoHideControlsTimer {
            timer.invalidate()
        }
    }

    func playerDidFinishPlaying() {
        isFullscreen = false
        isPlaying = false
    }

    func videoStatusChanged(newStatus: VideoPlayerViewStatus) {
        guard videoPlayerViewStatus != newStatus else { return }
        videoPlayerViewStatus = newStatus
    }

    func commercializerIntroShown() {
        UserDefaultsManager.sharedInstance.saveDidShowCommercializer()
    }

    func switchFullscreen() {
        isFullscreen = !isFullscreen
    }

    func switchControlsVisible() {
        controlsAreVisible = !controlsAreVisible
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
        guard 0..<themes.count ~= index else { return nil }
        return themes[index].objectId
    }

    func titleForThemeAtIndex(index: Int) -> String? {
        guard 0..<themes.count ~= index else { return nil }
        return themes[index].title
    }

    func imageUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard 0..<themes.count ~= index else { return nil }
        guard let urlString = themes[index].thumbURL else { return nil }
        return NSURL(string: urlString)
    }

    func videoUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard 0..<themes.count ~= index else { return nil }
        guard let urlString = themes[index].videoURL else { return nil }
        return NSURL(string: urlString)
    }

    func selectThemeAtIndex(index: Int) {
        selectedIndex = index
        guard let selectedThemeId = idForThemeAtIndex(selectedIndex) where selectedThemeId != themeId else { return }
        themeId = selectedThemeId
        guard let url = videoUrlForThemeAtIndex(selectedIndex) else { return }
        delegate?.viewModelDidSelectThemeWithURL(url)
    }

    func reloadSelectedTheme() {
        guard let url = videoUrlForThemeAtIndex(selectedIndex) else { return }
        delegate?.viewModelDidSelectThemeWithURL(url)
    }

    func promoteProduct() {
        delegate?.viewModelStartSendingVideoForProcessing()
        guard let productId = productId, themeId = themeId else {
            let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: promotionSource, status: .ProcessFail)
            delegate?.viewModelSentVideoForProcessing(processingViewModel, status: .ProcessFail)
            return
        }
        commercializerRepository.create(productId, templateId: themeId) { [weak self] result in
            if let strongSelf = self {
                if let _ = result.value {
                    let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: strongSelf.promotionSource, status: .ProcessOK)
                    strongSelf.delegate?.viewModelSentVideoForProcessing(processingViewModel, status: .ProcessOK)
                } else if let _ = result.error {
                    let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: strongSelf.promotionSource, status: .ProcessFail)
                    strongSelf.delegate?.viewModelSentVideoForProcessing(processingViewModel, status: .ProcessFail)
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
