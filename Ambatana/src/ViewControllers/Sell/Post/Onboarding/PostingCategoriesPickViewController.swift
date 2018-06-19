import Foundation
import LGCoreKit
import RxSwift
import LGComponents

class PostingCategoriesPickViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let cellHeight: CGFloat = 65

    private static let cellIdentifier = "PostListingCategoryCell"

    private let backButton: UIButton = UIButton()
    private let titleLabel: UILabel = UILabel()
    private let tableView: UITableView = UITableView()

    private var selectionEnabled: Bool = true

    var viewModel: PostingCategoriesPickViewModel

    let disposeBag = DisposeBag()

    init(viewModel: PostingCategoriesPickViewModel) {
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
        tableView.reloadData()
    }

    func setupUI() {
        view.backgroundColor = UIColor.white
        titleLabel.text = viewModel.titleText
        titleLabel.font = UIFont.systemSemiBoldFont(size: 17)
        backButton.setImage(viewModel.backButtonImage, for: .normal)
        backButton.tintColor = UIColor.primaryColor
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        tableView.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostListingCategoryCell.self,
                           forCellReuseIdentifier: PostingCategoriesPickViewController.cellIdentifier)
    }

    func setupConstraints() {
        let subviews = [backButton, titleLabel, tableView]
        view.addSubviews(subviews)
        view.setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: subviews)

        backButton.layout().height(Metrics.buttonHeight).height(Metrics.buttonHeight)
        backButton.layout(with: view).left(by: Metrics.bigMargin).top(by: Metrics.bigMargin)
        backButton.layout(with: tableView).above(by: -Metrics.bigMargin)

        titleLabel.layout(with: view).centerX()
        backButton.layout(with: titleLabel)
            .centerY()
            .trailing(by: -Metrics.bigMargin, relatedBy: .lessThanOrEqual)

        tableView.layout(with: view).left().right().bottom()
    }

    func setupRx() {
        backButton.rx.tap.bind { [weak self] in
            self?.viewModel.closeCategoriesPicker()
        }.disposed(by: disposeBag)
    }


    // MARK: TableViewDelegate & DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categoriesCount
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = PostingCategoriesPickViewController.cellIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? PostListingCategoryCell else {
            return UITableViewCell()
        }
        cell.updateWith(text: viewModel.categoryNameForCellAtIndexPath(indexPath: indexPath))
        cell.isSelected = viewModel.categorySelectedForIndexPath(indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectionEnabled else { return }
        selectionEnabled = false

        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        selectedCell.isSelected = true
        delay(0.3) { [weak self] in
            self?.viewModel.selectCategoryAtIndexPath(indexPath: indexPath)
            self?.selectionEnabled = true
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        selectedCell.isSelected = false
    }
}
