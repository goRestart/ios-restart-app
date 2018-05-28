//
//  ChatConversationsListViewController.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

final class ChatConversationsListViewController: BaseViewController {
    
    private let viewModel: ChatConversationsListViewModel
    private let contentView = ChatConversationsListView()
    
    private let featureFlags: FeatureFlaggeable
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "ic_more_options"), for: .normal)
        button.addTarget(self, action: #selector(optionsButtonPressed), for: .touchUpInside)
        button.set(accessibilityId: .chatConversationsListOptionsNavBarButton)
        return button
    }()
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(filtersButtonPressed), for: .touchUpInside)
        button.set(accessibilityId: .chatConversationsListFiltersNavBarButton)
        return button
    }()
    
    private let bag = DisposeBag()
    
    // MARK: Lifecycle
    
    convenience init(viewModel: ChatConversationsListViewModel) {
        self.init(viewModel: viewModel,
                  featureFlags: FeatureFlags.sharedInstance)
    }
    
    init(viewModel: ChatConversationsListViewModel,
         featureFlags: FeatureFlaggeable) {
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        super.init(viewModel: viewModel, nibName: nil)
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = false
        hasTabBar = true
    }
    
    override func loadView() {
        view = UIView()
        view.addSubviewForAutoLayout(contentView)
        NSLayoutConstraint.activate([
            safeTopAnchor.constraint(equalTo: contentView.topAnchor),
            safeBottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setReachabilityEnabled(false)
        setupViewModel()
        setupContentView()
        setupNavigationBarRx()
        setupViewStateRx()
        setupTableViewRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Navigation Bar
    
    private func setupNavigationBar(isEditing: Bool) {
        if isEditing {
            setLetGoRightButtonWith(barButtonSystemItem: .cancel,
                                    selector: #selector(cancelButtonPressed),
                                    animated: true)
        } else {
            setNavigationBarRightButtons([filtersButton, optionsButton],
                                         animated: true)
        }
    }
    
    // MARK: View model
    
    private func setupViewModel() {
        viewModel.deleteActionBlock = { [weak self] in
            self?.deleteButtonPressed()
        }
    }
    
    // MARK: UI
    
    private func setupContentView() {
        contentView.refreshControlBlock = { [weak self] in
            self?.viewModel.retrieveFirstPage(completion: { [weak self] in
                self?.contentView.endRefresh()
            })
        }
    }
    
    // MARK: Rx
    
    private func setupNavigationBarRx() {
        viewModel.rx_navigationBarTitle
            .asDriver()
            .drive(onNext: { [weak self] title in
                self?.setNavBarTitle(title)
            })
            .disposed(by: bag)
        
        viewModel.rx_navigationBarFilterButtonImage
            .asDriver()
            .drive(onNext: { [weak self] image in
                self?.filtersButton.setImage(image, for: .normal)
            })
            .disposed(by: bag)
        
        viewModel.rx_navigationActionSheet
            .asObservable()
            .bind { [weak self] (cancelTitle, actions) in
                self?.showActionSheet(cancelTitle, actions: actions)
            }
            .disposed(by: bag)
        
        viewModel.rx_isEditing
            .asDriver()
            .drive(onNext: { [weak self] isEditing in
                self?.setupNavigationBar(isEditing: isEditing)
            })
            .disposed(by: bag)
    }
    
    private func setupViewStateRx() {
        viewModel.rx_viewState
            .asDriver()
            .drive(onNext: { [weak self] viewState in
                switch viewState {
                case .loading:
                    self?.contentView.showActivityIndicator()
                case .data:
                    self?.contentView.showTableView()
                case .empty(let emptyViewModel):
                    self?.contentView.showEmptyView(with: emptyViewModel)
                case .error(let errorViewModel):
                    self?.contentView.showEmptyView(with: errorViewModel)
                }
            })
            .disposed(by: bag)
    }
    
    private func setupTableViewRx() {
        viewModel.rx_conversations
            .asObservable()
            .bind(to: contentView.rx_tableView
                .items(cellIdentifier: ConversationCell.reusableID,
                       cellType: ConversationCell.self)) { (row, conversation, cell) in
                        cell.textLabel?.text = conversation.interlocutor?.name
            }
            .disposed(by: bag)
        
        contentView.rx_tableView
            .modelSelected(ChatConversation.self)
            .bind { [weak self] conversation in
                self?.viewModel.openConversation(conversation)
            }
            .disposed(by: bag)
        
        contentView.rx_tableView
            .willDisplayCell // This is calling more cells than the visible ones!
            .asObservable()
            .bind { [weak self] (cell, index) in
                self?.viewModel.setCurrentIndex(index.row)
            }
            .disposed(by: bag)
    }
    
    // MARK: Actions
    
    @objc private func optionsButtonPressed() {
        viewModel.openOptionsActionSheet()
    }
    
    @objc private func filtersButtonPressed() {
        viewModel.openFiltersActionSheet()
    }
    
    @objc private func deleteButtonPressed() {
        viewModel.switchEditing()
    }
    
    @objc private func cancelButtonPressed() {
        viewModel.switchEditing()
    }
}
