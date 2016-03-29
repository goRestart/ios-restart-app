//
//  CommercialDisplayViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol CommercialDisplayViewModelDelegate: class {

}

public class CommercialDisplayViewModel: BaseViewModel {

    weak var delegate: CommercialDisplayViewModelDelegate?
    var commercialsList: [Commercializer]
    var selectedCommercial: Commercializer? {
        didSet {
            guard let shareUrl = selectedCommercial?.videoURL else { return }
            socialShareMessage = SocialHelper.socialMessageCommercializer("http://google.com", thumbUrl: selectedCommercial?.thumbURL)
        }
    }
    var numberOfCommercials: Int {
        return commercialsList.count
    }
    var socialShareMessage: SocialMessage?


    // MARK: - Lifercycle

    public init?(commercializers: [Commercializer]) {
        self.commercialsList = commercializers
        super.init()
        if commercializers.isEmpty { return nil }
    }


//    Commercializer.swift
//    var status: Int? { get }
//    var videoURL: String? { get }
//    var thumbURL: String? { get }
//    var shareURL: String? { get }
//    var templateId: String? { get }
//    var title: String? { get }
//    var duration: Int? { get }
//    var updatedAt : NSDate? { get }
//    var createdAt : NSDate? { get }


    // MARK: - public funcs

    func selectCommercialAtIndex(index: Int) {
        guard 0..<numberOfCommercials ~= index else { return }
        selectedCommercial = commercialsList[index]
    }

    func videoUrlAtIndex(index: Int) -> NSURL? {
        guard let videoUrl = commercialsList[index].videoURL else { return nil }
        return NSURL(string: videoUrl)
    }

    func thumbUrlAtIndex(index: Int) -> NSURL? {
        guard let thumbUrl = commercialsList[index].thumbURL else { return nil }
        return NSURL(string: thumbUrl)
    }

    func shareUrlAtIndex(index: Int) -> NSURL? {
        guard let shareURL = commercialsList[index].shareURL else { return nil }
        return NSURL(string: shareURL)
    }

    
}
