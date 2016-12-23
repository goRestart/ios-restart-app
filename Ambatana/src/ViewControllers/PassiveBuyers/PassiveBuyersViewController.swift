//
//  PassiveBuyersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PassiveBuyersViewController: BaseViewController, PassiveBuyersViewModelDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!

    private let header = UIView()
    private var headerTopMargin = NSLayoutConstraint()
    private let productImage = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    private let viewModel: PassiveBuyersViewModel


    // MARK: - View Lifecycle

    init(viewModel: PassiveBuyersViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "PassiveBuyersViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset.top = header.bottom
    }

    // MARK: - Private methods

    private func setupUI() {
        setupHeader()
        setupTable()
    }

    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(header, belowSubview: tableView)
        headerTopMargin = header.alignParentTop(margin: 64)
        header.fitHorizontallyToParent(margin: 0)

        productImage.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(productImage)
        productImage.setHeightConstraint(110)
        productImage.setWidthConstraint(110)
        productImage.alignParentTop()
        productImage.centerParentHorizontal()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        titleLabel.toBottomOf(productImage, margin: 20)
        titleLabel.fitHorizontallyToParent(margin: 40)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(messageLabel)
        messageLabel.toBottomOf(titleLabel, margin: 10)
        messageLabel.fitHorizontallyToParent(margin: 40)
        messageLabel.alignParentBottom(margin: 20)
    }
}


// MARK: - UITableView

extension PassiveBuyersViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 64
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
