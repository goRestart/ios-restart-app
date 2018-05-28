import UIKit
import LGCoreKit
import RxSwift
import LGComponents

final class ListingsMapViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private let viewModel : ListingsMapViewModel
    
    // MARK: - Subviews
    private let mapView = LGMapView()
    
    // MARK: - Lifecycle
    
    init(viewModel: ListingsMapViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nil)
        setupUI()
        setupRx()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationBar()
        setupMap()
    }
    
    // MARK: Private methods
    
    private func setupUI() {
        view.addSubviewsForAutoLayout([mapView])
        mapView.layout(with: view).fillHorizontal().bottom()
        mapView.layout(with: topLayoutGuide).top(to: .bottom)
    }
    
    private func updateNavigationBar() {
        setNavBarTitleStyle(.text(R.Strings.listingsMapTitle))
        setNavBarBackButton(#imageLiteral(resourceName: "navbar_back_red"), selector: #selector(ListingsMapViewController.onNavBarBack))
    }
    
    private func setupMap() {
        mapView.delegate = self
        mapView.updateMapRegion(location: viewModel.location, radiusAccuracy: viewModel.accuracy)
    }
    
    private func setupRx() {
        viewModel.listings
            .asDriver()
            .drive(onNext: { [weak self] listings in
                if let annotations = listings?.annotations {
                    self?.mapView.update(annotations: annotations)
                } else {
                    self?.mapView.resetMap()
                }
            }).disposed(by: disposeBag)
        viewModel.errorMessage
            .asObservable()
            .bind { [weak self] errorMessage in
                if let toastTitle = errorMessage {
                    self?.toastView?.title = toastTitle
                }
                self?.mapView.showMapError.value = errorMessage != nil
                self?.setToastViewHidden(errorMessage == nil)
            }.disposed(by: disposeBag)
        viewModel.selectedListing
            .asDriver()
            .drive(onNext: { [weak self] (listing, tags) in
                guard let listing = listing else { return }
                self?.mapView.updateDetail(with: listing, tags: tags)
            }).disposed(by: disposeBag)
        mapView.selectedAnnotationIndexVariable
            .asDriver()
            .drive(onNext: {[weak self] index in
                self?.viewModel.selectedListingsIndex.value = index
            }).disposed(by: disposeBag)
        viewModel.isLoading
            .asDriver()
            .drive(onNext: { [weak self] isLoading in
                self?.mapView.update(loading: isLoading)
        }).disposed(by: disposeBag)
    }
    
    @objc private func onNavBarBack() {
        popBackViewController()
    }
    
}

extension ListingsMapViewController: LGMapViewDelegate {

    func gpsButtonTapped() {
        // to be implemented in following interactions
    }
    
    func retryButtonTapped(location: LGLocationCoordinates2D, radius: Int) {
        viewModel.update(with: location, radius: radius)
    }
    
    func detailTapped(_ listing: Listing, originImageView: UIImageView?) {
        let imageFrameInVC = originImageView?.convert(originImageView?.frame ?? .zero, to: view)
        
        viewModel.open(.listingAPI(listing: listing,
                                   thumbnailImage: originImageView?.image,
                                   originFrame: imageFrameInVC))
    }

}
