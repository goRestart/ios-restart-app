import UIKit
import LGCoreKit
import LGComponents

final class UserRatingListViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate let viewModel: UserRatingListViewModel


    // MARK: Lifecycle

    required init(viewModel: UserRatingListViewModel, hidesBottomBarWhenPushed: Bool) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "UserRatingListViewController")
        self.viewModel.delegate = self
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
        setAccesibilityIds()
    }


    // MARK: private methods

    private func setupUI() {
        title = R.Strings.ratingListTitle
        tableView.register(type: UserRatingCell.self)

        tableView.isHidden = true
        view.backgroundColor = UIColor.listBackgroundColor
    }
}


// MARK: UserRatingListViewModelDelegate

extension UserRatingListViewController: UserRatingListViewModelDelegate {

    func vmIsLoadingUserRatingsRequest(_ isLoading: Bool, firstPage: Bool) {
        if isLoading && firstPage {
            activityIndicator.startAnimating()
        }
    }

    func vmDidLoadUserRatings(_ ratings: [UserRating], firstPage: Bool) {
        activityIndicator.stopAnimating()
        if !ratings.isEmpty {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

    func vmDidFailLoadingUserRatings(_ firstPage: Bool) {
        activityIndicator.stopAnimating()
        if firstPage {
            vmShowAutoFadingMessage(R.Strings.ratingListLoadingErrorMessage) { [weak self] in
                self?.navigationController?.popBackViewController()
            }
        }
    }

    func vmRefresh() {
        tableView.reloadData()
    }
}

// MARK: UITableView Delegate

extension UserRatingListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ratings.count
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeue(type: UserRatingCell.self, for: indexPath) else { return UITableViewCell() }

        guard let data = viewModel.dataForCellAtIndexPath(indexPath) else { return UITableViewCell() }
        cell.setupRatingCellWithData(data, indexPath: indexPath)
        cell.delegate = viewModel
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        viewModel.setCurrentIndex(indexPath.row)
    }
}


// MARK: - Accesibility

extension UserRatingListViewController {
    func setAccesibilityIds() {
        tableView.set(accessibilityId: .ratingListTable)
        activityIndicator.set(accessibilityId: .ratingListLoading)
    }
}
