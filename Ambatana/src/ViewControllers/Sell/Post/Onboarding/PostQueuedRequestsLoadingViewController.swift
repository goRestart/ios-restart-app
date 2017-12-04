//
//  PostQueuedRequestsLoadingViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

class PostQueuedRequestsLoadingViewController: BaseViewController {
    
    struct LoadingMetrics {
        static var heightLoadingView: CGFloat = 60
        static var widthLoadingView: CGFloat = 60
    }
    
    private var loadingView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: LoadingMetrics.widthLoadingView, height: LoadingMetrics.widthLoadingView))
    private let viewModel: PostQueuedRequestsLoadingViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: PostQueuedRequestsLoadingViewModel) {
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
//        viewModel.createListing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setStatusBarHidden(true)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.clipsToBounds = true
        view.backgroundColor = .clear
        loadingView.color = .white
        loadingView.startAnimating()
    }
    
    private func setupConstraints() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingView)
        
        loadingView.layout().height(LoadingMetrics.heightLoadingView).width(LoadingMetrics.widthLoadingView)
        loadingView.layout(with: view).centerY().centerX()
    }
    
    private func setupRx() {
        //        viewModel.finishRequest.asObservable().filter{ $0 == true }.bindNext { [weak self] finished in
        //            self?.viewModel.nextStep()
        //        }.addDisposableTo(disposeBag)
    }
}

