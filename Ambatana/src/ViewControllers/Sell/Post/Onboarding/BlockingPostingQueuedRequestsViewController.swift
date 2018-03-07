//
//  BlockingPostingQueuedRequestsViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

class BlockingPostingQueuedRequestsViewController: BaseViewController {
    
    struct LoadingMetrics {
        static var heightLoadingView: CGFloat = 60
        static var widthLoadingView: CGFloat = 60
    }
    
    private let tempNextButton = UIButton()
    
    private var loadingView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: LoadingMetrics.widthLoadingView, height: LoadingMetrics.widthLoadingView))
    private let viewModel: BlockingPostingQueuedRequestsViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(viewModel: BlockingPostingQueuedRequestsViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.uploadImages()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupRx() {
        viewModel.queueState.asObservable()
            .bind { [weak self] state in
                guard let strongSelf = self else { return }
                guard let state = state else { return }
                switch state {
                case .uploadingImages:
                    break
                case .createListing:
                    break
                case .createListingFake:
                    break
                case .listingPosted:
                    break
                case .error:
                    break
            }
        }
    }
}

