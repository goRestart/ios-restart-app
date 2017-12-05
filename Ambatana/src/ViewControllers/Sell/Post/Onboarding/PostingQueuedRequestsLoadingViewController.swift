//
//  PostingQueuedRequestsLoadingViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

class PostingQueuedRequestsLoadingViewController: BaseViewController {
    
    struct LoadingMetrics {
        static var heightLoadingView: CGFloat = 60
        static var widthLoadingView: CGFloat = 60
    }
    
    private var loadingView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: LoadingMetrics.widthLoadingView, height: LoadingMetrics.widthLoadingView))
    private let viewModel: PostingQueuedRequestsLoadingViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(viewModel: PostingQueuedRequestsLoadingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.setNavigationBarHidden(true, animated: false)
        setupConstraints()
        setupUI()
        setupRx()
        viewModel.createListing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setStatusBarHidden(true)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
    }
    
    private func setupConstraints() {
    }
    
    private func setupRx() {
    }
}

