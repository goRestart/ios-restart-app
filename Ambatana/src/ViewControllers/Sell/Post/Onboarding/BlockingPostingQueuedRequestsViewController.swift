//
//  BlockingPostingQueuedRequestsViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 04/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

class BlockingPostingQueuedRequestsViewController: BaseViewController, BlockingPostingLoadingViewDelegate {
    
    private static let closeButtonHeight: CGFloat = 52
    
    private let loadingView = BlockingPostingLoadingView()
    private let closeButton = UIButton()

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
        setupUI()
        setupConstraints()
        setupRx()
        viewModel.updateStateToUploadingImages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        if let state = viewModel.queueState.value, state.isAnimated {
            loadingView.updateWith(message: state.message, isError: state.isError, isAnimated: state.isAnimated)
        }
    }
    
    private func setupRx() {
        viewModel.queueState.asObservable()
            .bind { [weak self] state in
                guard let strongSelf = self else { return }
                guard let state = state else { return }
                strongSelf.loadingView.updateWith(message: state.message, isError: state.isError, isAnimated: state.isAnimated)
            }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        closeButton.addTarget(self, action: #selector(BlockingPostingListingEditionViewController.closeButtonAction), for: .touchUpInside)
        closeButton.setImage(UIImage(named: "ic_post_close"), for: .normal)
        
        loadingView.delegate = self
    }
    
    private func setupConstraints() {
        view.addSubviewsForAutoLayout([closeButton, loadingView])
        
        closeButton.layout(with: view)
            .top()
            .left()
        closeButton.layout()
            .height(BlockingPostingQueuedRequestsViewController.closeButtonHeight)
            .widthProportionalToHeight()
        
        loadingView.layout(with: view)
            .fillHorizontal()
            .bottom()
        loadingView.layout(with: closeButton).top(to: .bottom)
    }
    
    
    // MARK: - UI Actions
    
    @objc func closeButtonAction() {
        viewModel.closeButtonAction()
    }
    
    
    // MARK: - BlockingPostingLoadingViewDelegate
    
    func didPressRetryButton() {
        viewModel.updateStateToUploadingImages()
    }
}

