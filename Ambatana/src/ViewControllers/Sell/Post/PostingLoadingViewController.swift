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
    
    private var loadingView = LoadingIndicator()
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
        loadingView.color = UIColor.red
        loadingView.startAnimating()
    }
    
    private func setupRx() {
        viewModel.fisnishRequest.asObservable().filter{ $0 == true }.bindNext { [weak self] finished in
            guard let success = self?.viewModel.success else { return }
            self?.loadingView.stopAnimating(success, completion: { [weak self] _ in
                self?.viewModel.nextStep()
            })
        }.addDisposableTo(disposeBag)
    }
    
    private func setupConstraints() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loadingView)
        
        loadingView.layout().height(100).width(100)
        loadingView.layout(with: view).centerY().centerX()
    }
}
