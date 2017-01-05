//
//  CommercializerManager.swift
//  LetGo
//
//  Created by Eli Kohen on 01/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

struct CommercializerData {
    let productId: String
    let templateId: String
    let shouldShowPreview: Bool
    let isMyVideo: Bool
    let commercializer: Commercializer
}

private enum CommercializerManagerStatus {
    case pushRetrieval, checkingPending, idle
}

class CommercializerManager {

    // Singleton
    static let sharedInstance: CommercializerManager = CommercializerManager()

    let commercializers = PublishSubject<CommercializerData>()

    private var pendingTemplates: [String:[String]] = [:]
    private let commercializerRepository: CommercializerRepository
    private let sessionManager: SessionManager
    private let disposeBag = DisposeBag()

    private var status = CommercializerManagerStatus.idle

    convenience init() {
        self.init(commercializerRepository: Core.commercializerRepository, sessionManager: Core.sessionManager)
    }

    init(commercializerRepository: CommercializerRepository, sessionManager: SessionManager) {
        self.commercializerRepository = commercializerRepository
        self.sessionManager = sessionManager
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public methods

    func setup() {
        //Only for non-initial deep links
        DeepLinksRouter.sharedInstance.deepLinks.asObservable().subscribeNext { [weak self] deeplink in
            switch deeplink.action {
            case .CommercializerReady(let productId, let templateId):
                //If user is inside the app, show preview
                let applicationActive = UIApplication.shared.applicationState == .active
                self?.checkCommercializerAndShowPreview(productId: productId, templateIds: [templateId],
                    showPreview: applicationActive, isMyVideo: true, fromDeepLink: true)
            case .Commercializer(let productId, let templateId):
                self?.checkCommercializerAndShowPreview(productId: productId, templateIds: [templateId],
                    showPreview: false, isMyVideo: false, fromDeepLink: true)
            default: break
            }
        }.addDisposableTo(disposeBag)

        loadPendingTemplates()

        NotificationCenter.default.addObserver(self,
            selector: #selector(CommercializerManager.applicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        sessionManager.sessionEvents.filter { $0.isLogin }.bindNext{ [weak self] _ in
            self?.loadPendingTemplates()
            self?.refreshPendingTemplates()
        }.addDisposableTo(disposeBag)
    }

    func commercializerCreatedAndPending(productId: String, templateId: String) {
        if var templatesFromProductId = pendingTemplates[productId] {
            templatesFromProductId.append(templateId)
            pendingTemplates = [productId: templatesFromProductId]
        } else {
            pendingTemplates = [productId: [templateId]]
        }
        savePendingTemplates()
    }

    func commercializerReadyInitialDeepLink(productId: String, templateId: String) {
        //It comes from push notification or click on deeplink clicked by the user, so don't show preview
        checkCommercializerAndShowPreview(productId: productId, templateIds: [templateId], showPreview: false,
                                          isMyVideo: true, fromDeepLink: true)
    }


    // MARK: - Internal

    dynamic func applicationDidBecomeActive() {
        refreshPendingTemplates()
    }


    // MARK: - Private methods

    private func checkCommercializerAndShowPreview(productId: String, templateIds: [String],
                                                             showPreview: Bool, isMyVideo: Bool, fromDeepLink: Bool) {
        guard status == .idle else { return }

        status = fromDeepLink ? .pushRetrieval : .checkingPending
        commercializerRepository.index(productId) { [weak self] result in
            defer { self?.status = .Idle }
            guard let commercializers = result.value else { return }
            let filtered = commercializers.filter { commercializer in
                guard let templateId = commercializer.templateId, commercializer.status == .ready
                    else { return false }
                return templateIds.contains(templateId)
            }

            //If there are several ready just take one
            guard let commercializer = filtered.first, let templateId = commercializer.templateId else { return }
            self?.commercializerReady(productId: productId, templateId: templateId, commercializer: commercializer,
                                      showPreview: showPreview, isMyVideo: isMyVideo)
        }
    }

    private func commercializerReady(productId: String, templateId: String, commercializer: Commercializer,
                                               showPreview: Bool, isMyVideo: Bool) {
        //Clean up all other pending templates
        pendingTemplates = [:]
        savePendingTemplates()

        //Notify about it
        let data = CommercializerData(productId: productId, templateId: templateId,
                                      shouldShowPreview: showPreview, isMyVideo: isMyVideo, commercializer: commercializer)
        commercializers.onNext(data)
    }

    private func refreshPendingTemplates() {
        guard Core.sessionManager.loggedIn else { return }

        guard let productId = pendingTemplates.keys.first, let templates = pendingTemplates[productId] else { return }
        checkCommercializerAndShowPreview(productId: productId, templateIds: templates, showPreview: true,
                                          isMyVideo: true, fromDeepLink: false)
    }

    private func loadPendingTemplates() {
        guard Core.sessionManager.loggedIn else { return }
        pendingTemplates = KeyValueStorage.sharedInstance.userCommercializersPending
    }

    private func savePendingTemplates() {
        guard Core.sessionManager.loggedIn else { return }
        KeyValueStorage.sharedInstance.userCommercializersPending = pendingTemplates
   }
 }
