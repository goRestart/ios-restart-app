//
//  PostingLoadingViewController.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import Foundation
import LGCoreKit
import RxSwift

class PostingLoadingViewController: BaseViewController {
    
    struct LoadingMetrics {
        static var heightLoadingView: CGFloat = 100
        static var widthLoadingView: CGFloat = 100
    }
    
    private var loadingView = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: LoadingMetrics.widthLoadingView, height: LoadingMetrics.widthLoadingView))
    private let viewModel: PostingLoadingViewModel
    
    let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: PostingLoadingViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupConstraints()
        setupUI()
        setupRx()
        viewModel.createListing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        view.setNeedsLayout()
        view.layoutIfNeeded()
        loadingView.color = UIColor.white
        loadingView.startAnimating()
    }
    
    private func setupRx() {
        viewModel.fisnishRequest.asObservable().filter{ $0 == true }.bindNext { [weak self] finished in
            self?.viewModel.nextStep()
        }.addDisposableTo(disposeBag)
    }
    
    private func setupConstraints() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingView)
        
        loadingView.layout().height(LoadingMetrics.heightLoadingView).width(LoadingMetrics.widthLoadingView)
        loadingView.layout(with: view).centerY().centerX()
    }
}
