//
//  SearchAlertsListViewController.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 23/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

final class SearchAlertsListViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,
SearchAlertSwitchCellDelegate {

    private static let tableViewTopInset: CGFloat = 35
    private static let cellHeight: CGFloat = 50

    private let tableView = UITableView()
    private var rightBarButton: UIBarButtonItem = UIBarButtonItem()

    private let placeholderView = SearchAlertsPlaceholderView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private let viewModel: SearchAlertsListViewModel


    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    required init(viewModel: SearchAlertsListViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupRx()
        setupAccessibilityIds()
    }
    
    private func setupRx() {
        viewModel.searchAlerts.asDriver().drive(onNext: { [weak self] searchAlerts in
            if searchAlerts.count > 0 {
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
            } else {
                self?.tableView.isHidden = true
            }
        }).disposed(by: disposeBag)

        viewModel.searchAlertsState.asObservable().bind { [weak self] state in
            switch state {
            case .initial:
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
                self?.navigationItem.rightBarButtonItem = nil
                self?.placeholderView.isHidden = true
                self?.tableView.isHidden = true
            case .error, .empty:
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.navigationItem.rightBarButtonItem = nil
                self?.placeholderView.isHidden = false
                self?.tableView.isHidden = true
            case .full:
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.navigationItem.rightBarButtonItem = self?.rightBarButton
                self?.placeholderView.isHidden = true
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
            }
            self?.placeholderView.setupWith(state: state)
            }.disposed(by: disposeBag)

        placeholderView.actionButton.rx.tap.bind { [weak self] _ in
            self?.viewModel.placeholderButtonTapped()
        }.disposed(by: disposeBag)
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        title = LGLocalizedString.settingsNotificationsSearchAlerts
        
        tableView.isHidden = true
        placeholderView.isHidden = true
        tableView.allowsSelection = false

        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        automaticallyAdjustsScrollViewInsets = false

        tableView.backgroundColor = .grayBackground
        tableView.contentInset.top = SearchAlertsListViewController.tableViewTopInset
        tableView.separatorStyle = .none

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(SearchAlertSwitchCell.self, forCellReuseIdentifier: SearchAlertSwitchCell.reusableID)

        rightBarButton = UIBarButtonItem(title: LGLocalizedString.searchAlertsEditButton,
                                         style: .plain,
                                         target: self,
                                         action: #selector(triggerEditMode))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupConstraints() {
        view.addSubviewForAutoLayout(tableView)
        let tableConstraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: topBarHeight),
            tableView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
            ]
        NSLayoutConstraint.activate(tableConstraints)


        view.addSubviewForAutoLayout(placeholderView)
        let placeholderConstraints = [
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        NSLayoutConstraint.activate(placeholderConstraints)

        view.addSubviewForAutoLayout(activityIndicator)
        let activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(activityIndicatorConstraints)
    }

    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .settingsNotificationsTableView)
    }
    
    // MARK: - UIActions
    
    @objc private func triggerEditMode() {
        if !tableView.isEditing {
            tableView.isEditing = true
            navigationItem.rightBarButtonItem?.title = LGLocalizedString.commonDone
        } else {
            tableView.isEditing = false
            navigationItem.rightBarButtonItem?.title = LGLocalizedString.commonEdit
        }
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchAlerts.value.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchAlertsListViewController.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchAlertSwitchCell.reusableID, for: indexPath)
            as? SearchAlertSwitchCell else { return UITableViewCell() }
        cell.setupWithSearchAlert(viewModel.searchAlerts.value[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.deleteSearchAlertAtIndex(indexPath.row)
    }


    // MARK: - SearchAlertSwitchCellDelegate

    func didEnableSearchAlertWith(id: String, enable: Bool) {
        viewModel.triggerEnableOrDisable(searchAlertId: id, enable: enable)
    }
}
