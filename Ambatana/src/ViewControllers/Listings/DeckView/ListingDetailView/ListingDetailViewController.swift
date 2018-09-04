import Foundation
import LGComponents
import LGCoreKit
import RxSwift
import RxCocoa

final class ListingDetailViewController: BaseViewController {
    private enum Layout {
        static let buttonSize = CGSize(width: 40, height: 40)
    }
    fileprivate let detailView = ListingDetailView()

    let viewModel: ListingDetailViewModel
    private let disposeBag = DisposeBag()

    private let quickChatViewController: QuickChatViewController

    init(viewModel: ListingDetailViewModel) {
        self.viewModel = viewModel
        self.quickChatViewController = QuickChatViewController(listingViewModel: viewModel.listingViewModel)

        super.init(viewModel: viewModel,
                   nibName: nil,
                   statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .light),
                   swipeBackGestureEnabled: true)
        self.edgesForExtendedLayout = .all
        self.automaticallyAdjustsScrollViewInsets = false
        self.extendedLayoutIncludesOpaqueBars = true
        self.hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("Die xibs, die") }

    override func loadView() {
        self.view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addQuickChat()
        setupRx()
    }

    private func addQuickChat() {
        addChildViewController(quickChatViewController)
        detailView.addSubviewForAutoLayout(quickChatViewController.view)

        NSLayoutConstraint.activate([
            quickChatViewController.view.topAnchor.constraint(equalTo: safeTopAnchor),
            quickChatViewController.view.leadingAnchor.constraint(equalTo: detailView.leadingAnchor),
            quickChatViewController.view.trailingAnchor.constraint(equalTo: detailView.trailingAnchor),
            quickChatViewController.view.bottomAnchor.constraint(equalTo: safeBottomAnchor)
            ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    private func setupRx() {
        let bindings = [
            viewModel.rx.media.drive(rx.media),
            viewModel.rx.title.drive(rx.title),
            viewModel.rx.price.drive(rx.price),
            viewModel.rx.detail.drive(rx.detail),
            viewModel.rx.stats.drive(rx.stats),
            viewModel.rx.user.drive(rx.userInfo),
            viewModel.rx.location.drive(rx.location)
            ]
        bindings.forEach { $0.disposed(by: disposeBag) }
        detailView.rx
            .map
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
            self?.openMapView()
        }).disposed(by: disposeBag)
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        setupTransparentNavigationBar()
    }

    private func setupTransparentNavigationBar() {
        setLeftCloseButton()
    }

    override func viewDidFirstLayoutSubviews() {
        super.viewDidFirstLayoutSubviews()
        detailView.pageControlTop?.constant = statusBarHeight
    }

    private func setLeftCloseButton() {
        let button = UIButton(type: .custom)
        detailView.addSubviewForAutoLayout(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: detailView.topAnchor, constant: statusBarHeight + Metrics.shortMargin),
            button.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: Metrics.veryShortMargin),
            button.heightAnchor.constraint(equalToConstant: Layout.buttonSize.height),
            button.widthAnchor.constraint(equalToConstant: Layout.buttonSize.width)
        ])
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        button.setImage(R.Asset.IconsButtons.icCloseCarousel.image, for: .normal)
    }

    @objc private func closeView() {
        viewModel.closeDetail()
    }
}

extension ListingDetailViewController: DeckMapViewDelegate {
    func openMapView() {
        guard let data = viewModel.deckMapData else { return }
        let vc = DeckMapViewController(with: data)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func close(_ vc: DeckMapViewController) {
        dismiss(animated: true, completion: nil)
    }
}

private extension Reactive where Base: ListingDetailViewController {
    var media: Binder<[Media]> {
        return Binder(self.base) { controller, media in
            controller.detailView.populateWith(media: media)
        }
    }

    var title: Binder<String?> {
        return Binder(self.base) { controller, title in
            controller.detailView.populateWith(title: title)
        }
    }

    var price: Binder<String?> {
        return Binder(self.base) { controller, price in
            controller.detailView.populateWith(price: price)
        }
    }

    var detail: Binder<String?> {
        return Binder(self.base) { controller, detail in
            controller.detailView.populateWith(detail: detail)
        }
    }

    var stats: Binder<ListingDetailStats?> {
        return Binder(self.base) { controller, stats in
            controller.detailView.populateWith(stats: stats)
        }
    }

    var userInfo: Binder<ListingVMUserInfo> {
        return Binder(self.base) { controller, userInfo in
            controller.detailView.populateWith(userInfo: userInfo)
        }
    }

    var location: Binder<ListingDetailLocation?> {
        return Binder(self.base) { controller, location in
            controller.detailView.populateWith(location: location)
        }
    }
}
