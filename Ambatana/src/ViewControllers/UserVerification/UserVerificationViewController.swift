//
//  UserVerificationViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/3/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class UserVerificationViewController: BaseViewController {

    private let viewModel: UserVerificationViewModel
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let navBarView = UserVerificationNavBarView()
    private var items: [[UserVerificationItem]] = []

    private struct Layout {
        static let defaultRowHeight: CGFloat = 70
        static let markAsSoldRowHeight: CGFloat = 82
    }

    init(viewModel: UserVerificationViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        viewModel.delegate = self
        self.title = LGLocalizedString.profileVerificationsViewTitle
        setupUI()
        bindRx()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setNavBarBackgroundStyle(.white)
    }

    private func setupUI() {
        view.addSubviewForAutoLayout(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 66
        tableView.register(UserVerificationCell.self, forCellReuseIdentifier: UserVerificationCell.reusableID)
        setNavBarBackgroundStyle(.white)
        setupNavBar()
        setupConstraints()
    }

    private func setupNavBar() {
        let button = UIBarButtonItem(customView: navBarView)
        navigationItem.rightBarButtonItem = button
    }

    private func setupConstraints() {
        tableView.layout(with: view).fill()
    }

    private func bindRx() {
        viewModel.items.drive(onNext: { [weak self] items in
            self?.items = items
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        viewModel.userAvatar.drive(onNext: { [weak self] url in
            guard let avatarURL = url else { return }
            self?.navBarView.avatarImageView.lg_setImageWithURL(avatarURL)
        }).disposed(by: disposeBag)

        viewModel.userScore.drive(onNext: { [weak self] score in
            self?.navBarView.score = score
        }).disposed(by: disposeBag)
    }
}

extension UserVerificationViewController: UserVerificationViewModelDelegate {
    func startAvatarSelection() {
        MediaPickerManager.showImagePickerIn(self)
    }
}

extension UserVerificationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < items.count else { return 0 }
        return items[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserVerificationCell.reusableID,
                                                                       for: indexPath)
        guard let verifyCell = cell as? UserVerificationCell else { return UITableViewCell() }
        let item = items[indexPath.section][indexPath.row]
        verifyCell.configure(with: item)
        return verifyCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2: return Layout.markAsSoldRowHeight
        default: return Layout.defaultRowHeight
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.section][indexPath.row]
        guard item.canBeSelected else { return }
        viewModel.didSelect(item: item)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UserVerificationMainSectionHeader()
            view.title = LGLocalizedString.profileVerificationsViewVerifySectionTitle
            view.subtitle = LGLocalizedString.profileVerificationsViewVerifySectionSubtitle
            return view
        } else if section == 1 {
            let view = UserVerificationSectionHeader()
            view.title = LGLocalizedString.profileVerificationsViewAddInfoSectionTitle
            return view
        } else {
            let view = UserVerificationSectionHeader()
            view.title = LGLocalizedString.profileVerificationsViewExtraSectionTitle
            return view
        }
    }
}

extension UserVerificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
        dismiss(animated: true, completion: nil)
        guard let theImage = image else { return }
        viewModel.updateAvatar(with: theImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
