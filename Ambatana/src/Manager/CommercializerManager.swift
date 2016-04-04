//
//  CommercializerManager.swift
//  LetGo
//
//  Created by Eli Kohen on 01/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

struct CommercializerReadyData {
    let productId: String
    let templateId: String
    let shouldShowPreview: Bool
    let commercializer: Commercializer
}

class CommercializerManager {

    // Singleton
    static let sharedInstance: CommercializerManager = CommercializerManager()

    let commercializerReady = PublishSubject<CommercializerReadyData>()

    private let commercializerRepository: CommercializerRepository
    private let disposeBag = DisposeBag()

    init() {
        self.commercializerRepository = Core.commercializerRepository
    }

    // MARK: - Public methods

    func setup() {
        //Only for non-initial deep links
        DeepLinksRouter.sharedInstance.deepLinks.asObservable().subscribeNext { [weak self] deeplink in
            switch deeplink {
            case .CommercializerReady(let productId, let templateId):
                //If user is inside the app, show preview
                let applicationActive = UIApplication.sharedApplication().applicationState == .Active
                self?.checkCommercializerAndShowPreview(productId: productId, templateId: templateId,
                    showPreview: applicationActive)
            default: break
            }
        }.addDisposableTo(disposeBag)
    }

    func commercializerCreatedAndPending(productId productId: String, templateId: String) {
        
    }

    func commercializerReadyInitialDeepLink(productId productId: String, templateId: String) {
        //It comes from push notification or click on deeplink clicked by the user, so don't show preview
        checkCommercializerAndShowPreview(productId: productId, templateId: templateId, showPreview: false)
    }


    // MARK: - Private methods

    private func checkCommercializerAndShowPreview(productId productId: String, templateId: String, showPreview: Bool) {
        commercializerRepository.show(productId) { result in
            guard let commercializers = result.value else { return }
            commercializers.forEach { [weak self] commercializer in
                guard commercializer.templateId == productId else { return }

                let data = CommercializerReadyData(productId: productId, templateId: templateId,
                    shouldShowPreview: showPreview, commercializer: commercializer)
                self?.commercializerReady.onNext(data)
            }
        }
    }
 }