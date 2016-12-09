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
    case ProductEdit
    case ProductDetail
    case Settings
    
    var hasPostPromotionActions: Bool {
        switch self {
        case .ProductSell, .ProductEdit:
            return true
        case .ProductDetail, .Settings:
            return false
        }
    }

    var sourceForTracking: EventParameterTypePage {
        switch self {
        case .ProductSell:
            return .Sell
        case .ProductEdit:
            return .Edit
        case .ProductDetail:
            return .ProductDetail
        case .Settings:
            return .Settings
        }
    }
}


protocol PromoteProductViewModelDelegate: class {

    func viewModelDidRetrieveThemesListSuccessfully()
    func viewModelDidRetrieveThemesListWithError(errorMessage: String)
    func viewModelDidSelectThemeAtIndex(index: Int)

    func viewModelVideoDidSwitchFullscreen(isFullscreen: Bool)

    func viewModelStartSendingVideoForProcessing()
    func viewModelSentVideoForProcessing(processingViewModel: ProcessingVideoDialogViewModel, status: VideoProcessStatus)
    
    func viewModelWillRetrieveProductCommercials()
    func viewModelDidRetrieveProductCommercialsSuccessfully()
    func viewModelDidRetrieveProductCommercialsWithError()
}

public class PromoteProductViewModel: BaseViewModel {

    private let commercializerRepository: CommercializerRepository
    weak var delegate: PromoteProductViewModelDelegate?

    var productId: String?

    var playingIndex: Int = 0

    var promotionSource: PromotionSource
    private let themes: [CommercializerTemplate]
    private var availableThemes: [CommercializerTemplate]?
    private var commercializers: [Commercializer]?
    var themesCount: Int {
        return themes.count
    }
    var shouldShowOnboarding: Bool {
        return !KeyValueStorage.sharedInstance[.didShowCommercializer]
    }
    var isFullscreen: Bool = false {
        didSet {
            delegate?.viewModelVideoDidSwitchFullscreen(isFullscreen)
        }
    }
    var fullScreenButtonEnabled: Bool {
        return isFullscreen
    }

    
    // MARK: Lifecycle

    init?(commercializerRepository: CommercializerRepository, productId: String, themes: [CommercializerTemplate],
          commercializers: [Commercializer]?, promotionSource: PromotionSource) {

        self.commercializerRepository = commercializerRepository
        self.promotionSource = promotionSource
        self.themes = themes
        if let commercializers = commercializers {
            self.availableThemes = themes.availableTemplates(commercializers)
        }
        self.commercializers = commercializers
        self.productId = productId
        super.init()
        if themes.isEmpty { return nil }
    }
    
    convenience init?(productId: String, themes: [CommercializerTemplate], commercializers: [Commercializer]?,
                      promotionSource: PromotionSource) {
        let commercializerRepository = Core.commercializerRepository
        self.init(commercializerRepository: commercializerRepository, productId: productId, themes: themes,
                  commercializers: commercializers, promotionSource: promotionSource)
    }

  
    // MARK: - Public methods

    func viewDidLoad() {
        if availableThemes == nil {
            syncProductCommercials()
        }
    }
    
    func playerDidFinishPlaying() {
        isFullscreen = false
    }

    func commercializerIntroShown() {
        KeyValueStorage.sharedInstance[.didShowCommercializer] = true
    }

    var firstAvailableVideoIndex: Int? {
        for (index, theme) in themes.enumerate() {
            guard let themeId = theme.objectId, let templates = availableThemes else { continue }
            if templates.contains({ $0.objectId == themeId }) {
                return index
            }
        }
        return nil
    }

    func switchFullscreen() {
        isFullscreen = !isFullscreen
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
        guard let urlString = themes[index].videoM3u8URL else { return nil }
        return NSURL(string: urlString)
    }

    func availableThemeAtIndex(index: Int) -> Bool {
        guard 0..<themes.count ~= index else { return false }
        guard let themeId = themes[index].objectId, templates = availableThemes else { return false }
        return templates.contains { $0.objectId == themeId }
    }

    func playingThemeAtIndex(index: Int) -> Bool {
        return playingIndex == index
    }

    func playFirstAvailableTheme() {
        guard let index = firstAvailableVideoIndex else { return }
        playThemeAtIndex(index)
    }

    func playThemeAtIndex(index: Int) {
        guard 0..<themes.count ~= index else { return }
        playingIndex = index
        delegate?.viewModelDidSelectThemeAtIndex(index)
    }

    func promoteProduct() {
        delegate?.viewModelStartSendingVideoForProcessing()
        guard let productId = productId, themeId = idForThemeAtIndex(playingIndex) else {
            let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: promotionSource, status: .ProcessFail)
            delegate?.viewModelSentVideoForProcessing(processingViewModel, status: .ProcessFail)
            return
        }
        commercializerRepository.create(productId, templateId: themeId) { [weak self] result in
            if let strongSelf = self {
                if let _ = result.value {

                    let event = TrackerEvent.commercializerComplete(productId,
                        typePage: strongSelf.promotionSource.sourceForTracking, template: themeId)
                    TrackerProxy.sharedInstance.trackEvent(event)

                    let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: strongSelf.promotionSource,
                        status: .ProcessOK)
                    strongSelf.delegate?.viewModelSentVideoForProcessing(processingViewModel, status: .ProcessOK)

                    CommercializerManager.sharedInstance.commercializerCreatedAndPending(productId: productId,
                                                                                         templateId: themeId)
                } else if let error = result.error {

                    var paramError: EventParameterCommercializerError = .Internal
                    switch error {
                    case .Network, .NetworkFailedOnBackground:
                        paramError = .Network
                    case .Internal, .Forbidden, .NotFound, .Unauthorized, .TooManyRequests, .UserNotVerified, .ServerError:
                        break
                    }

                    let event = TrackerEvent.commercializerError(productId,
                        typePage: strongSelf.promotionSource.sourceForTracking, error: paramError)
                    TrackerProxy.sharedInstance.trackEvent(event)

                    let processingViewModel = ProcessingVideoDialogViewModel(promotionSource: strongSelf.promotionSource,
                        status: .ProcessFail)

                    strongSelf.delegate?.viewModelSentVideoForProcessing(processingViewModel, status: .ProcessFail)
                }
            }
        }
    }
    
    
    // MARK: Private methods
    
    private func syncProductCommercials() {
        guard let productId = productId else { return }
        delegate?.viewModelWillRetrieveProductCommercials()
        commercializerRepository.index(productId) { [weak self] result in
            if let value = result.value {
                self?.commercializers = value
                self?.availableThemes = self?.themes.availableTemplates(value)
                self?.delegate?.viewModelDidRetrieveProductCommercialsSuccessfully()
            } else {
                self?.delegate?.viewModelDidRetrieveProductCommercialsWithError()
            }
        }
    }
}
