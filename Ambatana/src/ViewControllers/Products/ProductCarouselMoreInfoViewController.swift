//
//  ProductCarouselMoreInfoViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit
import RxSwift
import LGCollapsibleLabel

class ProductCarouselMoreInfoViewController: BaseViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var autoTitleLabel: UILabel!
    @IBOutlet weak var transTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var socialShareTitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var descriptionLabel: LGCollapsibleLabel!
    @IBOutlet weak var reportProductHeightConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    let viewModel: ProductViewModel
    let overlayMap = MKMapView()
    let bigMapMargin: CGFloat = 70.0
    var bigMapVisible = false
    let dismissBlock: ((viewToHide: UIView) -> ())?
    
    init(viewModel: ProductViewModel, dismissBlock: ((viewToHide: UIView) -> ())?) {
        self.viewModel = viewModel
        self.dismissBlock = dismissBlock
        super.init(viewModel: viewModel, nibName: "ProductCarouselMoreInfoViewController",
                   statusBarStyle: .LightContent)
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
        addGestures()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        configureMapView()
    }
}


// MARK: - Gesture Intections 

extension ProductCarouselMoreInfoViewController {
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeView))
        visualEffectView.addGestureRecognizer(tap)
        scrollViewContent.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(tap)
    }
}


// MARK: - MapView stuff

extension ProductCarouselMoreInfoViewController {
    func configureMapView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showBigMap))
        mapView.addGestureRecognizer(tap)
        
        overlayMap.frame = mapView.bounds
        overlayMap.layer.cornerRadius = StyleHelper.mapCornerRadius
        overlayMap.clipsToBounds = true
        overlayMap.region = mapView.region

        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideBigMap))
        overlayMap.addGestureRecognizer(tapHide)
        
        overlayMap.alpha = 0
        view.addSubview(overlayMap)
    }
    
    func showBigMap() {
        guard !bigMapVisible else { return }
        bigMapVisible = true
        overlayMap.frame = view.convertRect(mapView.frame, fromView: scrollViewContent)
        overlayMap.region = mapView.region
        overlayMap.alpha = 1

        var newFrame = overlayMap.frame
        newFrame.origin.y = bigMapMargin
        newFrame.size.height = view.height - bigMapMargin*2
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.overlayMap.frame = newFrame
        }
    }
    
    func hideBigMap() {
        guard bigMapVisible else { return }
        bigMapVisible = false
        let span = mapView.region.span
        let newRegion = MKCoordinateRegion(center: overlayMap.region.center, span: span)
        mapView.region = newRegion
        let newFrame = view.convertRect(mapView.frame, fromView: scrollViewContent)
        UIView.animateWithDuration(0.3, animations: { [weak self] in
            self?.overlayMap.frame = newFrame
            }) { [weak self] completed in
                self?.overlayMap.alpha = 0
        }
    }
}


// MARK: - UI

extension ProductCarouselMoreInfoViewController {
    private func setupUI() {
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = StyleHelper.productTitleFont
        
        priceLabel.textColor = UIColor.whiteColor()
        priceLabel.font = StyleHelper.productPriceFont
        
        autoTitleLabel.textColor = UIColor.whiteColor()
        autoTitleLabel.font = StyleHelper.titleDisclaimersFont
        autoTitleLabel.alpha = 0.5
        
        transTitleLabel.textColor = UIColor.whiteColor()
        transTitleLabel.font = StyleHelper.titleDisclaimersFont
        transTitleLabel.alpha = 0.5
        
        addressLabel.textColor = UIColor.whiteColor()
        addressLabel.font = StyleHelper.productAddresFont
        
        distanceLabel.textColor = UIColor.whiteColor()
        distanceLabel.font = StyleHelper.productDistanceFont
        
        mapView.layer.cornerRadius = StyleHelper.mapCornerRadius
        mapView.clipsToBounds = true
        
        socialShareTitleLabel.textColor = UIColor.whiteColor()
        socialShareTitleLabel.font = StyleHelper.socialShareTitleFont
        
        reportButton.setStyle(.Dark)
        reportButton.titleLabel?.font = UIFont.defaultButtonFont
        
        reportProductHeightConstraint.constant = viewModel.productIsReportable.value ? 50 : 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescriptionState))
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.addGestureRecognizer(tapGesture)
        descriptionLabel.expandText = LGLocalizedString.commonExpand.uppercase
        descriptionLabel.collapseText = LGLocalizedString.commonCollapse.uppercase
        descriptionLabel.gradientColor = UIColor.clearColor()
        descriptionLabel.expandTextColor = UIColor.whiteColor()
        
        socialShareView.delegate = self
    }
    
    private func setupContent() {
        titleLabel.text = viewModel.productTitle.value
        priceLabel.text = viewModel.productPrice.value
        autoTitleLabel.text = viewModel.productTitleAutogenerated.value ?
            LGLocalizedString.productAutoGeneratedTitleLabel : nil
        transTitleLabel.text = viewModel.productTitleAutoTranslated.value ?
            LGLocalizedString.productAutoGeneratedTranslatedTitleLabel : nil
        
        addressLabel.text = viewModel.productAddress.value
        distanceLabel.text = "_50.0mi from you" // TODO
        
        socialShareTitleLabel.text = LGLocalizedString.productShareTitleLabel
        reportButton.setTitle(LGLocalizedString.productReportProductButton, forState: .Normal)
        
        viewModel.productDescription.asObservable().bindTo(descriptionLabel.rx_optionalMainText)
            .addDisposableTo(disposeBag)
        
        socialShareView.socialMessage = viewModel.socialMessage.value

        guard let coordinate = viewModel.productLocation.value else { return }
        let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegionMakeWithDistance(clCoordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
        mapView.zoomEnabled = false
    }
}

// MARK: - LGCollapsibleLabel

extension ProductCarouselMoreInfoViewController {
    func toggleDescriptionState() {
        UIView.animateWithDuration(0.25) {
            self.descriptionLabel.toggleState()
            self.view.layoutIfNeeded()
        }
    }
}


// MARK: - IB Actions

extension ProductCarouselMoreInfoViewController {
  
    @IBAction func reportProduct(sender: AnyObject) {
        viewModel.reportProduct()
    }
    
    @IBAction func closeView() {
        if bigMapVisible {
            hideBigMap()
        } else {
            dismissBlock?(viewToHide: view)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}


// MARK: - SocialShareViewDelegate

extension ProductCarouselMoreInfoViewController: SocialShareViewDelegate {
    
    func shareInEmail(){
        viewModel.shareInEmail(.Bottom)
    }
    
    func shareInEmailFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInEmailCompleted()
        case .Cancelled:
            viewModel.shareInEmailCancelled()
        case .Failed:
            break
        }
    }
    
    func shareInFacebook() {
        viewModel.shareInFacebook(.Bottom)
    }
    
    func shareInFacebookFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInFBCompleted()
        case .Cancelled:
            viewModel.shareInFBCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }
    
    func shareInFBMessenger() {
        viewModel.shareInFBMessenger()
    }
    
    func shareInFBMessengerFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInFBMessengerCompleted()
        case .Cancelled:
            viewModel.shareInFBMessengerCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.sellSendErrorSharingFacebook)
        }
    }
    
    func shareInWhatsApp() {
        viewModel.shareInWhatsApp()
    }
    
    func shareInTwitter() {
        viewModel.shareInTwitter()
    }
    
    func shareInTwitterFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInTwitterCompleted()
        case .Cancelled:
            viewModel.shareInTwitterCancelled()
        case .Failed:
            break
        }
    }
    
    func shareInTelegram() {
        viewModel.shareInTelegram()
    }
    
    func viewController() -> UIViewController? {
        return self
    }
    
    func shareInSMS() {
        viewModel.shareInSMS()
    }
    
    func shareInSMSFinished(state: SocialShareState) {
        switch state {
        case .Completed:
            viewModel.shareInSMSCompleted()
        case .Cancelled:
            viewModel.shareInSMSCancelled()
        case .Failed:
            showAutoFadingOutMessageAlert(LGLocalizedString.productShareSmsError)
        }
    }
    
    func shareInCopyLink() {
        viewModel.shareInCopyLink()
    }
}
