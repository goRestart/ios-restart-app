import LGComponents
import RxCocoa
import RxSwift
import UIKit

final class AffiliationChallengesDataView: UIView, UITableViewDataSource, UITableViewDelegate {
    private enum Layout {
        static let padding: CGFloat = 24
        static let estimatedSectionHeaderHeight: CGFloat = 295
        static let estimatedRowHeight: CGFloat = 225
    }

    private let refreshControl = UIRefreshControl()
    private let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        tableView.contentInset = UIEdgeInsets(top: Layout.padding,
                                              left: 0,
                                              bottom: Layout.padding,
                                              right: 0)
        tableView.estimatedSectionHeaderHeight = Layout.estimatedSectionHeaderHeight
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = Layout.estimatedSectionHeaderHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        tableView.register(AffiliationChallengesHeaderView.self,
                           forHeaderFooterViewReuseIdentifier: AffiliationChallengesHeaderView.reusableID)
        tableView.register(AffiliationChallengeInviteFriendsCell.self,
                           forCellReuseIdentifier: AffiliationChallengeInviteFriendsCell.ongoingIdentifier)
        tableView.register(AffiliationChallengeInviteFriendsCell.self,
                           forCellReuseIdentifier: AffiliationChallengeInviteFriendsCell.completedIdentifier)
        tableView.register(AffiliationChallengeJoinLetgoCell.self,
                           forCellReuseIdentifier: AffiliationChallengeJoinLetgoCell.ongoingIdentifier)
        tableView.register(AffiliationChallengeJoinLetgoCell.self,
                           forCellReuseIdentifier: AffiliationChallengeJoinLetgoCell.completedIdentifier)
        return tableView
    }()

    private var viewModel: AffiliationChallengesDataVM?
    var storeButtonPressedCallback: (() -> Void)?
    var faqButtonPressedCallback: (() -> Void)?
    var inviteFriendsButtonPressedCallback: (() -> Void)?
    var confirmPhonePressedCallback: (() -> Void)?
    var postListingPressedCallback: (() -> Void)?
    var refreshControlCallback: (() -> Void)?
    var isLoading: Binder<Bool> {
        return refreshControl.rx.isRefreshing
    }


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubviewForAutoLayout(tableView)
        let tableViewConstraints = [tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                    tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                    tableView.topAnchor.constraint(equalTo: topAnchor),
                                    tableView.bottomAnchor.constraint(equalTo: bottomAnchor)]
        tableViewConstraints.activate()

        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc private func refresh() {
        refreshControlCallback?()
    }


    // MARK: - Setup

    func set(viewModel: AffiliationChallengesDataVM) {
        self.viewModel = viewModel
        tableView.reloadData()
        refreshControl.endRefreshing()
    }


    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = viewModel else { return 0 }
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfChallenges
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let walletPoints = viewModel?.walletPoints,
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: AffiliationChallengesHeaderView.reusableID) as? AffiliationChallengesHeaderView else {
                return nil
        }
        header.set(walletPoints: walletPoints)
        header.tapCallback = storeButtonPressedCallback
        return header
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        guard let challenge = viewModel?.challengeAt(index: index) else { return UITableViewCell() }

        switch challenge {
        case .inviteFriends:
            return makeInviteFriendsChallengeCell(challenge: challenge,
                                                  indexPath: indexPath)
        case .joinLetgo:
            return makeJoinLetgoChallengeCell(challenge: challenge,
                                              indexPath: indexPath)
        }
    }

    private func makeInviteFriendsChallengeCell(challenge: Challenge,
                                                indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String
        switch challenge.status {
        case .ongoing:
            cellIdentifier = AffiliationChallengeInviteFriendsCell.ongoingIdentifier
        case .completed:
            cellIdentifier = AffiliationChallengeInviteFriendsCell.completedIdentifier
        }
        guard case let .inviteFriends(data) = challenge,
            let inviteFriendsCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                                  for: indexPath) as? AffiliationChallengeInviteFriendsCell else {
                                                                    return UITableViewCell()
        }
        inviteFriendsCell.setup(data: data)
        inviteFriendsCell.faqButtonPressedCallback = faqButtonPressedCallback
        inviteFriendsCell.inviteFriendsPressedCallback = inviteFriendsButtonPressedCallback
        return inviteFriendsCell
    }

    private func makeJoinLetgoChallengeCell(challenge: Challenge,
                                            indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String
        switch challenge.status {
        case .ongoing:
            cellIdentifier = AffiliationChallengeJoinLetgoCell.ongoingIdentifier
        case .completed:
            cellIdentifier = AffiliationChallengeJoinLetgoCell.completedIdentifier
        }
        guard case let .joinLetgo(data) = challenge,
            let joinLetgoCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                              for: indexPath) as? AffiliationChallengeJoinLetgoCell else {
                                                                return UITableViewCell()
        }
        joinLetgoCell.setup(data: data)
        let isPhoneConfirmed = data.stepsCompleted.contains(.phoneVerification)
        let isListingPosted = data.stepsCompleted.contains(.listingPosted)
        joinLetgoCell.buttonPressedCallback = { [weak self] in
            if !isPhoneConfirmed {
                self?.confirmPhonePressedCallback?()
            } else if !isListingPosted {
                self?.postListingPressedCallback?()
            }
        }
        joinLetgoCell.faqButtonPressedCallback = faqButtonPressedCallback
        return joinLetgoCell
    }
    

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
    }
}
