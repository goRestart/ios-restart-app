//
//  PassiveBuyersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 23/12/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class PassiveBuyersViewController: BaseViewController, PassiveBuyersViewModelDelegate {

    fileprivate static let headerTopMargin: CGFloat = 64

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var contactButton: UIButton!

    private let header = UIView()
    fileprivate var headerTopMarginConstraint = NSLayoutConstraint()
    fileprivate let productImage = UIImageView()
    fileprivate let titleLabel = UILabel()
    fileprivate let messageLabel = UILabel()

    fileprivate let viewModel: PassiveBuyersViewModel

    fileprivate let disposeBag = DisposeBag()


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
        setupUI()
        loadData()
    }

    override func viewDidFirstLayoutSubviews() {
        super.viewDidFirstLayoutSubviews()
        tableView.contentInset.top = header.bottom
    }


    // MARK: - Private methods

    private func setupUI() {
        topContainer.backgroundColor = UIColor.grayBackground
        topContainer.alpha = 0
        closeButton.setImage(UIImage(named: "navbar_close")?.withRenderingMode(.alwaysTemplate), for: .normal)

        setupHeader()
        setupTable()

        contactButton.setStyle(.primary(fontSize: .big))

        closeButton.rx.tap.subscribeNext { [weak self] in self?.viewModel.closeButtonPressed()}
            .addDisposableTo(disposeBag)
        contactButton.rx.tap.subscribeNext { [weak self] in self?.viewModel.contactButtonPressed()}
            .addDisposableTo(disposeBag)

        setAccesibilityIds()
    }

    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(header, belowSubview: tableView)
        header.layout(with: view).fillHorizontal().top(by: PassiveBuyersViewController.headerTopMargin,
                                                       constraintBlock: {[weak self] in self?.headerTopMarginConstraint = $0 })

        productImage.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(productImage)
        productImage.layout().width(110).widthProportionalToHeight()
        productImage.layout(with: header).top().centerX()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        titleLabel.layout(with: header).fillHorizontal(by: 40)
        titleLabel.layout(with: productImage).top(to: .bottom, by: 20)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(messageLabel)
        messageLabel.layout(with: header).fillHorizontal(by: 40).bottom(by: -20)
        messageLabel.layout(with: titleLabel).top(to: .bottom, by: 20)

        productImage.clipsToBounds = true
        productImage.cornerRadius = LGUIKitConstants.defaultCornerRadius
        productImage.contentMode = .scaleAspectFill

        titleLabel.textColor = UIColor.blackText
        titleLabel.font = UIFont.systemMediumFont(size: 17)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        messageLabel.textColor = UIColor.darkGrayText
        messageLabel.font = UIFont.mediumBodyFont
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
    }

    private func loadData() {
        productImage.image = UIImage(named: "product_placeholder")
        if let imageUrl = viewModel.productImage {
            productImage.lg_setImageWithURL(imageUrl)
        }

        titleLabel.text = LGLocalizedString.passiveBuyersTitle
        messageLabel.text = LGLocalizedString.passiveBuyersMessage

        contactButton.setTitle(LGLocalizedString.passiveBuyersButton(viewModel.buyersCount), for: .normal)

        tableView.reloadData()
    }
}


// MARK: - UITableView

extension PassiveBuyersViewController: UITableViewDelegate, UITableViewDataSource {
    fileprivate func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = PassiveBuyerCell.cellHeight

        let cellNib = UINib(nibName: PassiveBuyerCell.reusableID, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: PassiveBuyerCell.reusableID)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.buyersCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let buyerCell = tableView.dequeueReusableCell(withIdentifier: PassiveBuyerCell.reusableID,
                                    for: indexPath) as? PassiveBuyerCell else { return UITableViewCell() }
        let image = viewModel.buyerImageAtIndex(indexPath.row)
        let name = viewModel.buyerNameAtIndex(indexPath.row)

        buyerCell.setupWith(image, name: name, firstCell: indexPath.row == 0,
                            lastCell: indexPath.row == viewModel.buyersCount - 1)
        return buyerCell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scroll = scrollView.contentOffset.y + scrollView.contentInset.top
        headerTopMarginConstraint.constant = PassiveBuyersViewController.headerTopMargin - scroll

        topContainer.alpha = scroll.percentageBetween(start: productImage.top, end: productImage.bottom)
    }
}


// MARK: - Accesibility Ids

fileprivate extension PassiveBuyersViewController {
    func setAccesibilityIds() {
        titleLabel.accessibilityId = .passiveBuyersTitle
        messageLabel.accessibilityId = .passiveBuyersMessage
        contactButton.accessibilityId = .passiveBuyersContactButton
        tableView.accessibilityId = .passiveBuyersTable
    }
}
