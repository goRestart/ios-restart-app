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

    private var pendingTemplates: [String:[String]] = [:]
    private let commercializerRepository: CommercializerRepository
    private let disposeBag = DisposeBag()

    init() {
        self.commercializerRepository = Core.commercializerRepository
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Public methods

    func setup() {
        //Only for non-initial deep links
        DeepLinksRouter.sharedInstance.deepLinks.asObservable().subscribeNext { [weak self] deeplink in
            switch deeplink {
            case .CommercializerReady(let productId, let templateId):
                //If user is inside the app, show preview
                let applicationActive = UIApplication.sharedApplication().applicationState == .Active
                self?.checkCommercializerAndShowPreview(productId: productId, templateIds: [templateId],
                    showPreview: applicationActive)
            default: break
            }
        }.addDisposableTo(disposeBag)

        loadPendingTemplates()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: #selector(CommercializerManager.applicationWillEnterForeground),
            name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommercializerManager.loggedIn),
                                                         name: SessionManager.Notification.Login.rawValue, object: nil)
    }

    func commercializerCreatedAndPending(productId productId: String, templateId: String) {
        if var templatesFromProductId = pendingTemplates[productId] {
            templatesFromProductId.append(templateId)
            pendingTemplates[productId] = templatesFromProductId
        } else {
            pendingTemplates[productId] = [templateId]
        }
        savePendingTemplates()
    }

    func commercializerReadyInitialDeepLink(productId productId: String, templateId: String) {
        //It comes from push notification or click on deeplink clicked by the user, so don't show preview
        checkCommercializerAndShowPreview(productId: productId, templateIds: [templateId], showPreview: false)
    }


    // MARK: - Internal

    dynamic func applicationWillEnterForeground() {
        refreshPendingTemplates()
    }

    dynamic func loggedIn() {
        loadPendingTemplates()
        refreshPendingTemplates()
    }


    // MARK: - Private methods

    private func checkCommercializerAndShowPreview(productId productId: String, templateIds: [String], showPreview: Bool) {
        commercializerRepository.index(productId) { [weak self] result in
            guard let commercializers = result.value else { return }
            let filtered = commercializers.filter { commercializer in
                guard let templateId = commercializer.templateId else { return false }
                return templateIds.contains(templateId)
            }

            //Just take one
            guard let commercializer = filtered.first, templateId = commercializer.templateId else { return }
            self?.commercializerReady(productId: productId, templateId: templateId, commercializer: commercializer,
                                      showPreview: showPreview)
        }
    }

    private func commercializerReady(productId productId: String, templateId: String, commercializer: Commercializer,
                                               showPreview: Bool) {
        //Clean up all other pending templates
        pendingTemplates = [:]
        savePendingTemplates()

        //Notify about it
        let data = CommercializerReadyData(productId: productId, templateId: templateId,
                                           shouldShowPreview: true, commercializer: commercializer)
        commercializerReady.onNext(data)
    }

    private func refreshPendingTemplates() {
        guard Core.sessionManager.loggedIn else { return }

        for (productId, templates) in pendingTemplates {
            checkCommercializerAndShowPreview(productId: productId, templateIds: templates, showPreview: true)
            //Just check one product
            break
        }
    }

    private func loadPendingTemplates() {
        guard Core.sessionManager.loggedIn else { return }
        guard let pendingCommercializers = UserDefaultsManager.sharedInstance.loadPendingCommercializers() else {
            return
        }

        pendingTemplates = pendingCommercializers
    }

    private func savePendingTemplates() {
        guard Core.sessionManager.loggedIn else { return }

        UserDefaultsManager.sharedInstance.savePendingCommercializers(pendingTemplates)
    }
 }