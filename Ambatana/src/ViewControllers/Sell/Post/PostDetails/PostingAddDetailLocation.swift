import RxSwift
import MapKit
import LGCoreKit
import CoreLocation
import LGComponents

final class PostingAddDetailLocation: UIView, PostingViewConfigurable {
    
    private let bottomMessage = UILabel()
    private let searchMapView: LGSearchMap
    var locationSelected = Variable<Place?>(nil)
    private let searchMapViewModel: LGSearchMapViewModel
    private let disposeBag = DisposeBag()
    
    
    // MARK - Lifecycle
    
    init(viewControllerDelegate: LGSearchMapViewControllerModelDelegate, currentPlace: Place?) {
        self.searchMapViewModel = LGSearchMapViewModel(currentPlace: currentPlace)
        self.searchMapView = LGSearchMap(frame: CGRect.zero, viewModel: searchMapViewModel)
        super.init(frame: CGRect.zero)
        setupUI()
        setupConstraints()
        setupRx()
        searchMapView.viewModel.setViewControllerDelegate(viewControllerModelDelegate: viewControllerDelegate)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI
    
    private func setupUI() {
        bottomMessage.text = R.Strings.realEstateLocationNotificationMessage
        bottomMessage.font = UIFont.subtitleFont
        bottomMessage.textColor = UIColor.white
    }
    
    private func setupConstraints() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(for: [bottomMessage, searchMapView])
        addSubviews([bottomMessage, searchMapView])
        
        searchMapView.layout(with: self).top().fillHorizontal(by: Metrics.bigMargin)
        bottomMessage.layout(with: searchMapView).below(by: Metrics.margin).fillHorizontal()
        bottomMessage.layout(with: self).bottom(by: -(PostingDetailsViewController.skipButtonHeight+2*Metrics.bigMargin))
    }
    
    private func setupRx() {
        searchMapView.viewModel.placeLocation.asObservable()
            .bind(onNext: { [weak self] place in
                guard let place = place else { return }
                self?.locationSelected.value = place
            }).disposed(by: disposeBag)
    }
    
    // MARK: - PostingViewConfigurable
    
    func setupView(viewModel: PostingDetailsViewModel) {
        guard let location = viewModel.currentLocation else { return }
        searchMapView.updateCenterMap(location: location)
        
    }
    
    func setupContainerView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        layout(with: view).fill()
    }
    
    
}
