//
//  BlockingPostingListingEditionViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 07/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class BlockingPostingListingEditionViewController: BaseViewController, BlockingPostingLoadingViewDelegate {
    
    private static let closeButtonHeight: CGFloat = 52
    
    private let loadingView = BlockingPostingLoadingView()
    private let closeButton = UIButton()
    
    private let viewModel: BlockingPostingListingEditionViewModel
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - LifeCycle
    
    init(viewModel: BlockingPostingListingEditionViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupUI()
        setupRx()
        viewModel.updateListing()
    }
    
    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        if let state = viewModel.state.value,
            state == .updatingListing {
            loadingView.updateToLoading(message: state.message)
        }
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
            .height(BlockingPostingListingEditionViewController.closeButtonHeight)
            .widthProportionalToHeight()
        
        loadingView.layout(with: view)
            .fillHorizontal()
            .bottom()
        loadingView.layout(with: closeButton).top(to: .bottom)
    }
    
    private func setupRx() {
        viewModel.state.asObservable().distinctUntilChanged { (s1, s2) -> Bool in
            s1 == s2
        }.bind { [weak self] state in
            guard let strongSelf = self else { return }
            guard let state = state else { return }
            strongSelf.closeButton.isHidden = !(state == .error)
                
            switch state {
            case .updatingListing:
                strongSelf.loadingView.updateToLoading(message: state.message)
            case .success:
                strongSelf.loadingView.updateToSuccess(message: state.message)
                strongSelf.viewModel.openListingPosted()
            case .error:
                strongSelf.loadingView.updateToError(message: state.message)
            }
        }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI Actions
    
    @objc func closeButtonAction() {
        viewModel.closeButtonAction()
    }
    
    
    // MARK: - BlockingPostingLoadingViewDelegate
    
    func didPressRetryButton() {
        viewModel.updateListing()
    }
}
