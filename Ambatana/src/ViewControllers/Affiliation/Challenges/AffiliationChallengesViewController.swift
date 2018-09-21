import LGComponents
import RxSwift
import RxCocoa
import UIKit

final class AffiliationChallengesViewController: BaseViewController {
    private let viewModel: AffiliationChallengesViewModel
    private let dataView: AffiliationChallengesDataView = {
        let view = AffiliationChallengesDataView()
        view.isHidden = true
        return view
    }()
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.startAnimating()
        view.isHidden = true
        return view
    }()
    private let errorView: AffiliationStoreErrorView = {
        let view = AffiliationStoreErrorView()
        view.isHidden = true
        return view
    }()
    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(viewModel: AffiliationChallengesViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel,
                   nibName: nil,
                   navBarBackgroundStyle: .white)
        setupUI()
        setAccessibilityIds()
        setupRx()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        title = R.Strings.affiliationChallengesTitle
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBar()
        setupLoadingView()
        setupDataView()
        setupErrorView()
    }

    private func setupNavigationBar() {
        let button = UIBarButtonItem(image: R.Asset.Affiliation.icnReward24.image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(storeButtonPressed))
        button.tintColor = .grayRegular
        navigationItem.rightBarButtonItems = [button]
    }

    @objc private func storeButtonPressed() {
        viewModel.storeButtonPressed()
    }

    private func setupLoadingView() {
        view.addSubviewForAutoLayout(loadingView)
        let constraints = [loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                           loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        constraints.activate()
    }

    private func setupDataView() {
        view.addSubviewForAutoLayout(dataView)
        let constraints = [dataView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                           dataView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                           dataView.topAnchor.constraint(equalTo: safeTopAnchor),
                           dataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        constraints.activate()

        dataView.storeButtonPressedCallback = { [weak viewModel] in
            viewModel?.storeButtonPressed()
        }
        dataView.faqButtonPressedCallback = { [weak viewModel] in
            viewModel?.faqButtonPressed()
        }
        dataView.inviteFriendsButtonPressedCallback = { [weak viewModel] in
            viewModel?.inviteFriendsButtonPressed()
        }
        dataView.confirmPhonePressedCallback = { [weak viewModel] in
            viewModel?.confirmPhoneButtonPressed()
        }
        dataView.postListingPressedCallback = { [weak viewModel] in
            viewModel?.postListingButtonPressed()
        }
        dataView.refreshControlCallback = { [weak viewModel] in
            viewModel?.refreshControlPulled()
        }
    }

    private func setupErrorView() {
        view.addSubviewForAutoLayout(errorView)
        let constraints = [errorView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
                           errorView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
                           errorView.topAnchor.constraint(equalTo: safeTopAnchor),
                           errorView.bottomAnchor.constraint(equalTo: safeBottomAnchor)]
        constraints.activate()
    }

    private func setAccessibilityIds() {

    }

    private func setupRx() {
        viewModel.state.drive(onNext: { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .firstLoad:
                self.dataView.isHidden = true
                self.loadingView.isHidden = false
                self.errorView.isHidden = true
            case let .data(dataVM):
                self.dataView.isHidden = false
                self.loadingView.isHidden = true
                self.errorView.isHidden = true
                self.dataView.set(viewModel: dataVM)
            case .error(let errorModel):
                self.dataView.isHidden = true
                self.loadingView.isHidden = true
                self.errorView.isHidden = false
                if let buttonTitle = errorModel.buttonTitle,
                    let action = errorModel.action,
                    let message = errorModel.title,
                    let image = errorModel.icon {
                    let action = UIAction(interface: .button(buttonTitle,
                                                             .primary(fontSize: .medium)),
                                          action: action)
                    self.errorView.populate(message: message,
                                            image: image,
                                            action: action)
                }
            }
        }).disposed(by: disposeBag)
    }
}
