//
//  PostProductGalleryView.swift
//  LetGo
//
//  Created by Eli Kohen on 04/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

protocol PostProductGalleryViewDelegate: class {
    func productGalleryCloseButton()
    func productGalleryDidSelectImages(images: [UIImage])
    func productGalleryRequestsScrollLock(lock: Bool)
    func productGalleryDidPressTakePhoto()
    func productGalleryShowActionSheet(cancelAction: UIAction, actions: [UIAction])
    func productGallerySelectionFull(selectionFull: Bool)
}

class PostProductGalleryView: BaseView, LGViewPagerPage {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageContainerTop: NSLayoutConstraint!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var imageLoadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadImageErrorView: UIView!
    @IBOutlet weak var loadImageErrorTitleLabel: UILabel!
    @IBOutlet weak var loadImageErrorSubtitleLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionGradientView: UIView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var postButton: UIButton!

    private var albumButtonTick = UIImageView()

    // Error & empty
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoSubtitle: UILabel!
    @IBOutlet weak var infoButton: UIButton!

    weak var delegate: PostProductGalleryViewDelegate? {
        didSet {
            viewModel.galleryDelegate = delegate
        }
    }

    var visible: Bool {
        set {
            viewModel.visible.value = newValue
        }
        get {
            return viewModel.visible.value
        }
    }

    var usePhotoButtonText: String? {
        set {
            postButton?.setTitle(newValue, forState: UIControlState.Normal)
        }
        get {
            return postButton?.titleForState(UIControlState.Normal)
        }
    }
    private var headerShown = true

    // Drag & state vars
    var dragState: GalleryDragState = .None
    var initialDragPosition: CGFloat = 0
    var collapsed = false

    private var viewModel: PostProductGalleryViewModel

    private var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    convenience init(multiSelectionEnabled: Bool) {
        let viewModel = PostProductGalleryViewModel(multiSelectionEnabled: multiSelectionEnabled)
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }

    init(viewModel: PostProductGalleryViewModel, frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        self.viewModel.delegate = self
        setupUI()
    }

    init?(viewModel: PostProductGalleryViewModel, coder aDecoder: NSCoder) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, coder: aDecoder)
        self.viewModel.delegate = self
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        collectionGradientView.layer.sublayers?.forEach{ $0.frame = collectionGradientView.bounds }
        collectionView.contentInset.top = imageContainer.height
    }


    // MARK: - Public methods

    func showHeader(show: Bool) {
        guard headerShown != show else { return }
        headerShown = show
        let destinationAlpha: CGFloat = show ? 1.0 : 0.0
        UIView.animateWithDuration(0.2) { [weak self] in
            self?.headerContainer.alpha = destinationAlpha
        }
    }

    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        delegate?.productGalleryCloseButton()
    }

    @IBAction func postButtonPressed(sender: AnyObject) {
        viewModel.postButtonPressed()
    }


    // MARK: - Private methods

    private func setupUI() {
        NSBundle.mainBundle().loadNibNamed("PostProductGalleryView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        contentView.backgroundColor = UIColor.blackColor()
        addSubview(contentView)

        postButton.setStyle(.Primary(fontSize: .Small))
        
        let cellNib = UINib(nibName: GalleryImageCell.reusableID, bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: GalleryImageCell.reusableID)
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4.0
        }

        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = collectionGradientView.bounds
        collectionGradientView.layer.addSublayer(shadowLayer)

        infoButton.setStyle(.Primary(fontSize: .Medium))
        loadImageErrorTitleLabel.text = LGLocalizedString.productPostGalleryLoadImageErrorTitle
        loadImageErrorSubtitleLabel.text = LGLocalizedString.productPostGalleryLoadImageErrorSubtitle

        setAccesibilityIds()
        setupRX()
        setupAlbumSelection()
    }
}


// MARK: - PostProductGalleryViewDelegate

extension PostProductGalleryView: PostProductGalleryViewModelDelegate {

    func vmDidUpdateGallery() {
        collectionView.reloadData()
    }

    func vmDidSelectItemAtIndex(index: Int, shouldScroll: Bool) {
        animateToState(collapsed: false) { [weak self] in
            self?.selectItemAtIndex(index)
        }
    }

    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {
        delegate?.productGalleryShowActionSheet(cancelAction, actions: actions)
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PostProductGalleryView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imagesCount
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return viewModel.cellSize
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            guard let galleryCell = collectionView.dequeueReusableCellWithReuseIdentifier(GalleryImageCell.reusableID,
                forIndexPath: indexPath) as? GalleryImageCell else { return UICollectionViewCell() }
            viewModel.imageForCellAtIndex(indexPath.row) { image in
                galleryCell.image.image = image
            }
            galleryCell.multipleSelectionEnabled = viewModel.multiSelectionEnabled
            if viewModel.positionsSelected.value.contains(indexPath.item) {
                galleryCell.disabled = false
                galleryCell.selected = true
                collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                if let position = viewModel.positionsSelected.value.indexOf(indexPath.item) {
                    galleryCell.multipleSelectionCountLabel.text = "\(position + 1)"
                }
            } else if viewModel.imagesSelectedCount.value >= viewModel.maxImagesSelected {
                galleryCell.disabled = viewModel.multiSelectionEnabled
                galleryCell.selected = false
            } else {
                galleryCell.selected = false
                galleryCell.disabled = false
            }
            return galleryCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.imageSelectedAtIndex(indexPath.row)
    }

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return viewModel.imageSelectionEnabled.value
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.imageDeselectedAtIndex(indexPath.row)
    }

    func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return viewModel.multiSelectionEnabled
    }

    private func selectItemAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        let layoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        if let layoutAttributes = layoutAttributes {
            collectionView.scrollRectToVisible(layoutAttributes.frame, animated: true)
        }
    }

    private func deselectItemAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        let layoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        if let layoutAttributes = layoutAttributes {
            collectionView.scrollRectToVisible(layoutAttributes.frame, animated: true)
        }
    }
}


// MARK: - Info screen

extension PostProductGalleryView {

    private func setupRX() {
        viewModel.galleryState.asObservable().subscribeNext{ [weak self] state in
            self?.loadImageErrorView.hidden = true
            self?.imageLoadActivityIndicator.stopAnimating()
            switch state {
            case .Empty:
                self?.infoTitle.text = LGLocalizedString.productPostEmptyGalleryTitle
                self?.infoSubtitle.text = LGLocalizedString.productPostEmptyGallerySubtitle
                self?.infoButton.setTitle(LGLocalizedString.productPostEmptyGalleryButton, forState: .Normal)
                self?.infoContainer.hidden = false
                self?.postButton.enabled = false
            case .PendingAskPermissions:
                self?.infoTitle.text = LGLocalizedString.productPostGalleryPermissionsTitle
                self?.infoSubtitle.text = LGLocalizedString.productPostGalleryPermissionsSubtitle
                self?.infoButton.setTitle(LGLocalizedString.productPostGalleryPermissionsButton, forState: .Normal)
                self?.infoContainer.hidden = false
                self?.postButton.enabled = false
                self?.postButton.enabled = false
            case .MissingPermissions(let msg):
                self?.infoTitle.text = LGLocalizedString.productPostGalleryPermissionsTitle
                self?.infoSubtitle.text = msg
                self?.infoButton.setTitle(LGLocalizedString.productPostGalleryPermissionsButton, forState: .Normal)
                self?.infoContainer.hidden = false
                self?.postButton.enabled = false
                self?.postButton.enabled = false
            case .Normal:
                self?.infoContainer.hidden = true
                self?.postButton.enabled = true
            case .LoadImageError:
                self?.infoContainer.hidden = true
                self?.loadImageErrorView.hidden = false
                self?.postButton.enabled = false
            case .Loading:
                self?.imageLoadActivityIndicator.startAnimating()
                self?.postButton.enabled = false
            }
        }.addDisposableTo(disposeBag)

        viewModel.imagesSelected.asObservable().bindNext { [weak self] imgsSelected in
            self?.collectionView.reloadData()
        }.addDisposableTo(disposeBag)

        viewModel.imageSelectionEnabled.asObservable().distinctUntilChanged().bindNext { [weak self] interactionEnabled in
            self?.delegate?.productGallerySelectionFull(!interactionEnabled)
        }.addDisposableTo(disposeBag)
    }

    @IBAction func onInfoButtonPressed(sender: AnyObject) {
        viewModel.infoButtonPressed()
    }
}


// MARK: - Album selection 

extension PostProductGalleryView {

    func setupAlbumSelection() {

        albumButtonTick.image = UIImage(named: "ic_down_triangle")?.imageWithRenderingMode(.AlwaysTemplate)
        albumButtonTick.tintColor = UIColor.whiteColor()
        albumButtonTick.translatesAutoresizingMaskIntoConstraints = false
        albumButton.addSubview(albumButtonTick)
        let left = NSLayoutConstraint(item: albumButtonTick, attribute: .Left, relatedBy: .Equal,
            toItem: albumButton.titleLabel, attribute: .Right, multiplier: 1.0, constant: 8)
        let centerV = NSLayoutConstraint(item: albumButtonTick, attribute: .CenterY, relatedBy: .Equal,
            toItem: albumButton, attribute: .CenterY, multiplier: 1.0, constant: 2)
        albumButton.addConstraints([left,centerV])


        viewModel.albumTitle.asObservable().bindTo(albumButton.rx_title).addDisposableTo(disposeBag)
        viewModel.albumButtonEnabled.asObservable().bindTo(albumButton.rx_enabled).addDisposableTo(disposeBag)
        viewModel.lastImageSelected.asObservable().bindTo(selectedImage.rx_image).addDisposableTo(disposeBag)

        viewModel.albumIconState.asObservable().subscribeNext{ [weak self] status in
            switch status{
            case .Hidden:
                self?.albumButtonTick.hidden = true
            case .Down:
                self?.albumButtonTick.hidden = false
                self?.animateAlbumTickDirectionTop(false)
            case .Up:
                self?.albumButtonTick.hidden = false
                self?.animateAlbumTickDirectionTop(true)
            }
        }.addDisposableTo(disposeBag)
    }

    @IBAction func albumButtonPressed(sender: AnyObject) {
        viewModel.albumButtonPressed()
    }

    private func animateAlbumTickDirectionTop(top: Bool) {
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            self?.albumButtonTick.transform = CGAffineTransformMakeRotation(top ? CGFloat(M_PI) : 0)
        })
    }
}


// MARK: - Dragging

enum GalleryDragState {
    case None, DraggingCollection(Bool), DraggingImage
}

extension PostProductGalleryView: UIGestureRecognizerDelegate {

    var imageContainerMaxHeight: CGFloat {
        return imageContainer.height-headerContainer.height
    }

    var imageContainerStateThreshold: CGFloat {
        return 50
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panRecognizer.velocityInView(contentView)
        let panningVertically = fabs(velocity.y) > fabs(velocity.x)
        return panningVertically
    }

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(contentView)

        switch recognizer.state {
        case .Began:
            if location.y < imageContainer.height+imageContainerTop.constant {
                dragState = .DraggingImage
            } else {
                dragState = .DraggingCollection(false)
            }
            initialDragPosition = imageContainerTop.constant
            delegate?.productGalleryRequestsScrollLock(true)
        case .Ended:
            dragState = .None
            collectionView.userInteractionEnabled = true
            finishAnimating()
            delegate?.productGalleryRequestsScrollLock(false)
        default:
            handleDrag(recognizer)
        }
    }

    private func handleDrag(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.locationInView(contentView)
        let translation = recognizer.translationInView(contentView)
        switch dragState {
        case .DraggingImage:
            imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
            syncCollectionWithImage()
        case .DraggingCollection(let fromTop):
            if location.y < imageContainer.height+imageContainerTop.constant {
                imageContainerTop.constant = max(min(0, -(imageContainer.height-20-location.y)), -imageContainerMaxHeight)
                syncCollectionWithImage()
                collectionView.userInteractionEnabled = false
            } else if (imageContainerTop.constant < 0) && (collectionView.contentOffset.y <= 0 || fromTop) {
                imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
                syncCollectionWithImage()
                dragState = .DraggingCollection(true)
            } else if !fromTop {
                recognizer.setTranslation(CGPoint(x:0, y:0), inView: contentView)
            }
        case .None:
            break
        }
    }

    private func finishAnimating() {
        if collapsed {
            let shouldExpand = abs(imageContainerTop.constant) < imageContainerMaxHeight-imageContainerStateThreshold
            animateToState(collapsed: !shouldExpand, completion: nil)
        } else {
            let shouldCollapse = abs(imageContainerTop.constant) > imageContainerStateThreshold
            animateToState(collapsed: shouldCollapse, completion: nil)
        }
    }

    private func animateToState(collapsed collapsed: Bool, completion: (() -> Void)?) {
        imageContainerTop.constant = collapsed ? -imageContainerMaxHeight : 0
        self.collapsed = collapsed

        UIView.animateWithDuration(0.2,
            animations: { [weak self] in
                self?.syncCollectionWithImage()
                self?.contentView.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            }
        )
    }

    private func syncCollectionWithImage() {
        collectionView.contentInset.top = imageContainer.height + imageContainerTop.constant
    }
}


// MARK: - Accesibility

extension PostProductGalleryView {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .PostingGalleryCloseButton
        imageContainer.accessibilityId = .PostingGalleryImageContainer
        imageLoadActivityIndicator.accessibilityId = .PostingGalleryLoading
        collectionView.accessibilityId = .PostingGalleryCollection
        albumButton.accessibilityId = .PostingGalleryAlbumButton
        postButton.accessibilityId = .PostingGalleryUsePhotoButton
        infoButton.accessibilityId = .PostingGalleryInfoScreenButton
    }
}
