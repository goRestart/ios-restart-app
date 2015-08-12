//
//  ProductViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import MapKit
import UIKit
import SDWebImage

public class ProductViewController: BaseViewController, GalleryViewDelegate, ProductViewModelDelegate {

    // Constants
    private static let bottomViewVisibleHeight: CGFloat = 64
    private static let footerViewVisibleHeight: CGFloat = 64
    
    // UI
    // > Main
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    // > Bottom
    @IBOutlet weak var bottomViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    // > Footer
    @IBOutlet weak var footerViewHeightConstraint: NSLayoutConstraint!
    
    // >> Other selling
    @IBOutlet weak var otherSellingView: UIView!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var offerButton: UIButton!
    
    // >> Me selling
    @IBOutlet weak var meSellingView: UIView!
    @IBOutlet weak var markSoldButton: UIButton!
    
    // ViewModel
    private var viewModel : ProductViewModel!
    
    // MARK: - Lifecycle
    
    public init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ProductViewController")
        
        self.viewModel.delegate = self
        
        automaticallyAdjustsScrollViewInsets = false
        hidesBottomBarWhenPushed = true
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
    
    @IBAction func mapViewButtonPressed(sender: AnyObject) {
        openMap()
    }
    
    @IBAction func shareFBButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func shareEmailButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func shareWhatsAppButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func reportButtonPressed(sender: AnyObject) {
        report()
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        delete()
    }
    
    @IBAction func askButtonPressed(sender: AnyObject) {
        ask()
    }
    
    @IBAction func offerButtonPressed(sender: AnyObject) {
        offer()
    }
    
    @IBAction func markSoldPressed(sender: AnyObject) {
        markSold()
    }
    
    // MARK: - GalleryViewDelegate
    
    public func galleryView(galleryView: GalleryView, didPressPageAtIndex index: Int) {
        // TODO: Refactor into GalleryViewController with proper MVVM
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PhotosInDetailViewController") as! PhotosInDetailViewController
        
        // add the images
        var imageURLs : [NSURL] = []
        for i in 0..<viewModel.numberOfImages {
            if let imageURL = viewModel.imageURLAtIndex(i) {
                imageURLs.append(imageURL)
            }
        }
        vc.imageURLs = imageURLs
        vc.initialImageToShow = index
        vc.productName = viewModel.name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        // Setup
        galleryView.delegate = self
        
        // i18n
        askButton.setTitle(NSLocalizedString("product_ask_a_question_button", comment: ""), forState: .Normal)
        offerButton.setTitle(NSLocalizedString("product_make_an_offer_button", comment: ""), forState: .Normal)
        markSoldButton.setTitle(NSLocalizedString("product_mark_as_sold_button", comment: ""), forState: .Normal)
        
        // Update the UI
        updateUI()
    }
    
    private func updateUI() {
        // Navigation Bar
        self.setLetGoNavigationBarStyle(title: "")
        
        // Gallery
        for i in 0..<viewModel.numberOfImages {
            if let imageURL = viewModel.imageURLAtIndex(i) {
                galleryView.addPageWithImageAtURL(imageURL)
            }
        }
        
        // Main
        userAvatarImageView.layer.cornerRadius = CGRectGetWidth(userAvatarImageView.frame) / 2
        userAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor;
        userAvatarImageView.layer.borderWidth = 2
        if let userAvatarURL = viewModel.userAvatar {
            userAvatarImageView.sd_setImageWithURL(userAvatarURL, placeholderImage: UIImage(named: "no_photo"))
        }
        usernameContainerView.layer.cornerRadius = 2
        usernameLabel.text = viewModel.userName
        
        nameLabel.text = viewModel.name
        priceLabel.text = viewModel.price
        descriptionLabel.text = viewModel.descr
        addressLabel.text = viewModel.address
        if let location = viewModel.location {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
        
        // Bottom (shown when pending OR approved, otherwise if it's not mine so other users can still report it)
        let bottomViewVisible: Bool
        switch viewModel.status {
        case .Pending:
            bottomViewVisible = true
            break
        case .Approved:
            bottomViewVisible = true
            break
        case .Discarded:
            bottomViewVisible = !viewModel.isMine
            break
        case .Sold:
            bottomViewVisible = !viewModel.isMine
            break
        case .Deleted:
            bottomViewVisible = !viewModel.isMine
            break
        }
        bottomViewHeightContraint.constant = bottomViewVisible ? ProductViewController.bottomViewVisibleHeight : 0
        reportButton.hidden = viewModel.isMine
        deleteButton.hidden = !viewModel.isMine
        
        // Footer (shown if approved)
        let footerViewVisible: Bool
        switch viewModel.status {
        case .Pending:
            footerViewVisible = false
            break
        case .Approved:
            footerViewVisible = true
            break
        case .Discarded:
            footerViewVisible = false
            break
        case .Sold:
            footerViewVisible = false
            break
        case .Deleted:
            footerViewVisible = false
            break
        }
        footerViewHeightConstraint.constant = footerViewVisible ? ProductViewController.footerViewVisibleHeight : 0
        
        // Footer other / me selling subviews
        otherSellingView.hidden = viewModel.isMine
        meSellingView.hidden = !viewModel.isMine
    }
    
    // MARK: > Actions
    
    private func openMap() {
        
    }
    
    private func report() {
        viewModel.report()
    }
    
    private func delete() {
        viewModel.delete()
    }
    
    private func ask() {
        viewModel.ask()
    }
    
    private func offer() {
        viewModel.offer()
    }
    
    private func edit() {
        viewModel.edit()
    }
    
    private func markSold() {
        viewModel.markSold()
    }
}
