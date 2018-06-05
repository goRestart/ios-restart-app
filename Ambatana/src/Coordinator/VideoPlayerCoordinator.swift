//
//  VideoPlayerCoordinator.swift
//  LetGo
//
//  Created by Facundo Menzella on 24/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class VideoPlayerCoordinator: Coordinator, PhotoViewerNavigator {
    var child: Coordinator?
    weak var coordinatorDelegate: CoordinatorDelegate?
    var viewController: UIViewController { return navigationController }
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    var sessionManager: SessionManager
    private let navigationController: UINavigationController

    private var quickChatViewModel: QuickChatViewModel? = nil


    convenience init?(atIndex index: Int,
                     listingVM: ListingViewModel,
                     source: EventParameterListingVisitSource) {
        self.init(atIndex: index,
                  listingVM: listingVM,
                  source: source,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init?(atIndex index: Int,
         listingVM: ListingViewModel,
         source: EventParameterListingVisitSource,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.bubbleNotificationManager = bubbleNotificationManager
        guard let displayable = listingVM.makeDisplayable(forMediaAt: index) else { return nil }
        
        let vm = PhotoViewerViewModel(with: displayable, source: source)

        let chatVM: QuickChatViewModel = QuickChatViewModel()
        chatVM.listingViewModel = listingVM
        let vc = PhotoViewerViewController(viewModel: vm, quickChatViewModel: chatVM)
        self.navigationController = UINavigationController(rootViewController: vc)

        quickChatViewModel = chatVM
        vm.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }

    func closePhotoViewer() {
        quickChatViewModel = nil
        closeCoordinator(animated: true, completion: nil)
    }
}
