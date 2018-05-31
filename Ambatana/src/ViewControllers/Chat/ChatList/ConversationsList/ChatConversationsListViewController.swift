//
//  ChatConversationsListViewController.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import RxSwift
import RxDataSources
import LGCoreKit
import LGComponents

final class ChatConversationsListViewController: BaseViewController {
    
    private let viewModel: ChatConversationsListViewModel
    private let contentView = ChatConversationsListView()
    
    private let featureFlags: FeatureFlaggeable
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.Asset.IconsButtons.icMoreOptions.image, for: .normal)
        button.addTarget(self, action: #selector(navigationBarOptionsButtonPressed), for: .touchUpInside)
        button.set(accessibilityId: .chatConversationsListOptionsNavBarButton)
        return button
    }()
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(navigationBarFiltersButtonPressed), for: .touchUpInside)
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
                                    selector: #selector(navigationBarCancelButtonPressed),
                                    animated: true)
        } else {
            setNavigationBarRightButtons([filtersButton, optionsButton],
                                         animated: true)
        }
    }
    
    // MARK: View model
    
    private func setupViewModel() {
        viewModel.deleteConversationConfirmationBlock = { [weak self] conversation in
            let alert = UIAlertController(title: ChatConversationsListViewModel.Localize.deleteAlertConfirmationTitle,
                                          message: ChatConversationsListViewModel.Localize.deleteAlertConfirmationMessage,
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: ChatConversationsListViewModel.Localize.buttonCancel,
                                             style: .cancel,
                                             handler: nil)
            let okAction = UIAlertAction(title: ChatConversationsListViewModel.Localize.deleteAlertConfirmationButtonOk,
                                              style: .destructive) { [weak self]  (_) -> Void in
                self?.viewModel.deleteConversation(conversation: conversation)
            }
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self?.present(alert, animated: true, completion: nil)
        }
        viewModel.deleteConversationDidStartBlock = { [weak self] message in
            self?.showLoadingMessageAlert(message)
        }
        viewModel.deleteConversationDidSuccessBlock = { [weak self] in
            self?.dismissLoadingMessageAlert()
        }
        viewModel.deleteConversationDidFailBlock = { [weak self] message in
            self?.dismissLoadingMessageAlert(message, afterMessageCompletion: { [weak self] in
                self?.viewModel.retrieveFirstPage()
            })
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
                self?.contentView.switchEditMode(isEditing: false)
                self?.showActionSheet(cancelTitle, actions: actions)
            }
            .disposed(by: bag)
        
        viewModel.rx_isEditing
            .asDriver()
            .drive(onNext: { [weak self] isEditing in
                self?.setupNavigationBar(isEditing: isEditing)
                self?.contentView.switchEditMode(isEditing: isEditing)
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
        let dataSource = RxTableViewSectionedAnimatedDataSource<ChatConversationsListSectionModel>(
            configureCell: { (_, tableView, indexPath, item) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatUserConversationCell.reusableID)
                    as? ChatUserConversationCell else { return UITableViewCell() }
                cell.setupCellWith(data: item.conversationCellData, indexPath: indexPath)
                return cell
        },
            canEditRowAtIndexPath: { (_, _) in
            return true
        }
        )
        dataSource.decideViewTransition = { (_, _, changeSet) in
            return RxDataSources.ViewTransition.reload
        }

        viewModel.rx_conversations
            .asObservable()
            .map { [ChatConversationsListSectionModel(conversations: $0, header: "conversations")] }
            .bind(to: contentView.rx_tableView.items(dataSource: dataSource))
            .disposed(by: bag)
        
        contentView.rx_tableView
            .itemSelected
            .bind { [weak self] indexPath in
                self?.viewModel.tableViewDidSelectItem(at: indexPath)
            }
            .disposed(by: bag)
        
        contentView.rx_tableView
            .itemDeleted
            .bind { [weak self] indexPath in
                self?.viewModel.tableViewDidDeleteItem(at: indexPath)
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
    
    // MARK: Navigation Bar Actions
    
    @objc private func navigationBarOptionsButtonPressed() {
        viewModel.openOptionsActionSheet()
    }
    
    @objc private func navigationBarFiltersButtonPressed() {
        viewModel.openFiltersActionSheet()
    }
    
    @objc private func navigationBarCancelButtonPressed() {
        viewModel.switchEditMode(isEditing: false)
    }
}
