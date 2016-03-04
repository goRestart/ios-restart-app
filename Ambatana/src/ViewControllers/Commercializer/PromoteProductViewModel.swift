//
//  PromoteProductViewModel.swift
//  LetGo
//
//  Created by Dídac on 01/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol PromoteProductViewModelDelegate: class {

    func viewModelVideoDidSwitchFullscreen(isFullscreen: Bool)
    func viewModelVideoDidSwitchControlsVisible(controlsAreVisible: Bool)
    func viewModelVideoDidSwitchPlaying(isPlaying: Bool)
    func viewModelVideoDidSwitchAudio(videoIsMuted: Bool)

    func viewModelDidSelectThemeWithURL(themeURL: NSURL)

    func viewModelSentVideoForProcessing()
}

public class PromoteProductViewModel: BaseViewModel {

    weak var delegate: PromoteProductViewModelDelegate?

    var themes: [AnyObject]? // will be an array of "Themes"
    
    var themesCount: Int {
        guard let items = themes else { return 0 }
        return items.count
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

    // MARK: Lifecycle

    init(themes: [AnyObject]) {
        super.init()
        self.themes = themes
    }

    convenience override init() {
        let mockupThemes = [ ["thumb":"http://cdn.stg.letgo.com/images/5c/45/28/1e/5c45281ebc4ff9419b66a35484ba5545_thumb.jpg",
            "title":"theme 1",
            "video":"https://d3tzvxyypxy6x8.cloudfront.net/ub0aDaAaL3G4h-F3Y7reP-T5qd34u-m6NaH0i-Sdx4s0Zbf9e9q4J0xeae99E6/U1Lbd1Q8LaJ2d7z-98Q2leE293laM1F2l8y3.mp4"],
            ["thumb":"http://cdn.stg.letgo.com/images/4b/8d/7d/e3/4b8d7de3528fc476ff79f75997d3c8cd_thumb.jpg",
                "title":"theme 2",
                "video":"https://d3tzvxyypxy6x8.cloudfront.net/ub0aDaAaL3G4h-F3Y7reP-T5qd34u-m6NaH0i-Sdx4s0Zbf9e9q4J0xeae99E6/U1Lbd1Q8LaJ2d7z-98Q2leE293laM1F2l8y3.mp4"],
            ["thumb":"http://cdn.stg.letgo.com/images/2b/a2/bb/ad/2ba2bbad5948fa6b860066865b718ce5_thumb.jpg",
                "title":"theme 3",
                "video":"https://d3tzvxyypxy6x8.cloudfront.net/ub0aDaAaL3G4h-F3Y7reP-T5qd34u-m6NaH0i-Sdx4s0Zbf9e9q4J0xeae99E6/U1Lbd1Q8LaJ2d7z-98Q2leE293laM1F2l8y3.mp4"],
            ["thumb":"http://cdn.stg.letgo.com/images/b8/84/f7/9e/b884f79e17c7c686f596f75e0d668c9a_thumb.jpg",
                "title":"theme 4",
                "video":"https://d3tzvxyypxy6x8.cloudfront.net/ub0aDaAaL3G4h-F3Y7reP-T5qd34u-m6NaH0i-Sdx4s0Zbf9e9q4J0xeae99E6/U1Lbd1Q8LaJ2d7z-98Q2leE293laM1F2l8y3.mp4"],
            ["thumb":"http://cdn.stg.letgo.com/images/45/05/af/01/4505af01783dfc881528f0db29af6673_thumb.jpg",
                "title":"theme 5",
                "video":"https://d3tzvxyypxy6x8.cloudfront.net/ub0aDaAaL3G4h-F3Y7reP-T5qd34u-m6NaH0i-Sdx4s0Zbf9e9q4J0xeae99E6/U1Lbd1Q8LaJ2d7z-98Q2leE293laM1F2l8y3.mp4"]
        ]

        self.init(themes:mockupThemes)
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
        guard index < themes?.count else { return nil }
        guard let item = themes?[index] else { return nil }
        guard let title = item["title"] as? String else { return nil }
        return title
    }

    func imageUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard index < themes?.count else { return nil }
        guard let item = themes?[index] else { return nil }
        guard let urlString = item["thumb"] as? String else { return nil }
        return NSURL(string: urlString)
    }

    func videoUrlForThemeAtIndex(index: Int) -> NSURL? {
        guard index < themes?.count else { return nil }
        guard let item = themes?[index] else { return nil }
        guard let urlString = item["video"] as? String else { return nil }
        return NSURL(string: urlString)
    }

    func selectThemeAtIndex(index: Int) {
        guard let url = videoUrlForThemeAtIndex(index) else { return }
        delegate?.viewModelDidSelectThemeWithURL(url)
    }

    func promoteVideo() {
        print("upload video to queue!!!")
        delegate?.viewModelSentVideoForProcessing()
    }

    // MARK: private methods

    private func startAutoHidingControlsTimer() {
        autoHideControlsTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "autoHideControls", userInfo: nil, repeats: false)
        if let autoHideControlsTimer = autoHideControlsTimer where !controlsAreVisible || !autoHideControlsEnabled {
            autoHideControlsTimer.invalidate()
        }
    }
}
