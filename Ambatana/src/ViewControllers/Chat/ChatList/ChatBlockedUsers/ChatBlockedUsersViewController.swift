//
//  ChatBlockedUsersViewController.swift
//  LetGo
//
//  Created by Dídac on 10/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import UIKit
import RxSwift


final class ChatBlockedUsersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView: UITableView = UITableView()
    private let emptyView: LGEmptyView = LGEmptyView()

    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    private let viewModel: ChatBlockedUsersViewModel
    private var disposeBag = DisposeBag()

    init(viewModel: ChatBlockedUsersViewModel) {
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
        setupAccessibilityIds()
    }

    private func setupUI() {
        title = LGLocalizedString.chatListBlockedUsersTitle

        setupTableView()

        tableView.isHidden = true
        emptyView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    private func setupTableView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        tableView.register(ChatBlockedUserCell.self, forCellReuseIdentifier: ChatBlockedUserCell.reusableID)

        tableView.backgroundColor = .grayBackground
        tableView.separatorStyle = .none

        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupRx() {
        viewModel.blockedUserList.asDriver().skip(1).drive(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.viewStatus.asDriver().skip(1).drive(onNext: { [weak self] status in
            switch status {
            case .empty(let vm), .error(let vm):
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.emptyView.setupWithModel(vm)
                self?.emptyView.isHidden = false
                self?.tableView.isHidden = true
            case .loading:
                self?.activityIndicator.isHidden = false
                self?.activityIndicator.startAnimating()
                self?.emptyView.isHidden = true
                self?.tableView.isHidden = true
            case .data:
                self?.activityIndicator.isHidden = true
                self?.activityIndicator.stopAnimating()
                self?.emptyView.isHidden = true
                self?.tableView.isHidden = false
                self?.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
    }


    private func setupConstraints() {
        view.addSubviewForAutoLayout(tableView)
        let tableConstraints = [
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: topBarHeight),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(tableConstraints)

        view.addSubviewForAutoLayout(emptyView)
        let emptyViewConstraints = [
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(emptyViewConstraints)

        view.addSubviewForAutoLayout(activityIndicator)
        let activityIndicatorConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(activityIndicatorConstraints)
    }

    private func setupAccessibilityIds() {
        tableView.set(accessibilityId: .chatBlockedUsersTableView)
        emptyView.set(accessibilityId: .chatBlockedUsersEmptyView)
    }


    // MARK: - UITableViewDelegate & UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.blockedUsersCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChatBlockedUserCell.defaultHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatBlockedUserCell.reusableID) as? ChatBlockedUserCell,
            let user = viewModel.objectAt(index: indexPath.row) else {
                return UITableViewCell()
        }
        cell.setupCellWithUser(user, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedBlockedUserAt(index: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.unblockSelectedUserAt(index: indexPath.row)
    }
}