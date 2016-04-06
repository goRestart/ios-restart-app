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
    case Settings
    
    var hasPostPromotionActions: Bool {
        switch self {
        case .ProductSell:
            return true
        case .ProductDetail, .Settings:
            return false
        }
    }
}


protocol PromoteProductViewModelDelegate: class {

    func viewModelDidRetrieveThemesListSuccessfully()
    func viewModelDidRetrieveThemesListWithError(errorMessage: String)
    func viewModelDidSelectThemeWithURL(themeURL: NSURL)

    func viewModelVideoDidSwitchFullscreen(isFullscreen: Bool)

    func viewModelStartSendingVideoForProcessing()
    func viewModelSentVideoForProcessing(processingViewModel: ProcessingVideoDialogViewModel, status: VideoProcessStatus)
}

public class PromoteProductViewModel: BaseViewModel {

    private let commercializerRepository: CommercializerRepository
    weak var delegate: PromoteProductViewModelDelegate?

    var productId: String?
    var themeId: String?

    var selectedIndex: Int = 0

    var promotionSource: PromotionSource
    var themes: [CommercializerTemplate]
    var themesCount: Int {
        return themes.count
    }
    var commercializerShownBefore: Bool {
        return UserDefaultsManager.sharedInstance.loadDidShowCommercializer()
    }
    var isFullscreen: Bool = false {
        didSet {
            delegate?.viewModelVideoDidSwitchFullscreen(isFullscreen)
        }
    }
    var fullScreenButtonEnabled: Bool {
        return isFullscreen
    }

    var statusBarStyleAtDisappear: UIStatusBarStyle {
        switch promotionSource {
        case .ProductSell, .Settings:
            return .Default
        case .ProductDetail:
            return .LightContent
        }
    }

    
    // MARK: Lifecycle

    init?(commercializerRepository: CommercializerRepository, productId: String, themes: [CommercializerTemplate], promotionSource: PromotionSource) {
        self.commercializerRepository = commercializerRepository
        self.promotionSource = promotionSource
        self.themes = themes
        self.productId = productId
        super.init()
        if themes.isEmpty { return nil }
    }

    convenience init?(productId: String, themes: [CommercializerTemplate], promotionSource: PromotionSource) {
        let commercializerRepository = Core.commercializerRepository
        self.init(commercializerRepository: commercializerRepository, productId: productId, themes: themes, promotionSource: promotionSource)
    }


    // MARK: - Public methods

    func playerDidFinishPlaying() {
        isFullscreen = false
    }

    func commercializerIntroShown() {
        UserDefaultsManager.sharedInstance.saveDidShowCommercializer()
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
        guard let urlString = themes[index].videoHighURL else { return nil }
        return NSURL(string: urlString)
    }

    func selectThemeAtIndex(index: Int) {
        selectedIndex = index
        guard let selectedThemeId = idForThemeAtIndex(selectedIndex) where selectedThemeId != themeId else { return }
        themeId = selectedThemeId
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
}
