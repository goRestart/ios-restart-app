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
    func productGalleryDidSelectImage(image: UIImage)
    func productGalleryRequestsScrollLock(lock: Bool)
    func productGalleryDidPressTakePhoto()
    func productGalleryShowActionSheet(cancelAction: UIAction, actions: [UIAction])
}

class PostProductGalleryView: BaseView {

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imageContainerTop: NSLayoutConstraint!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionGradientView: UIView!
    @IBOutlet weak var headerContainer: UIView!
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

    convenience init() {
        self.init(viewModel: PostProductGalleryViewModel(), frame: CGRect.zero)
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

        postButton.setPrimaryStyle()
        postButton.setBackgroundImage(StyleHelper.postProductDisabledPostButton
            .imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        postButton.titleLabel?.font = StyleHelper.smallButtonFont

        let cellNib = UINib(nibName: GalleryImageCell.reusableID, bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: GalleryImageCell.reusableID)
        collectionView.alwaysBounceVertical = true
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4.0
        }

        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = collectionGradientView.bounds
        collectionGradientView.layer.addSublayer(shadowLayer)

        setupInfoView()

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
            return galleryCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.imageSelectedAtIndex(indexPath.row)
    }

    private func selectItemAtIndex(index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        let layoutAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        if let layoutAttributes = layoutAttributes {
            collectionView.scrollRectToVisible(layoutAttributes.frame, animated: true)
        }
    }
}


// MARK: - Info screen

extension PostProductGalleryView {

    private func setupInfoView() {
        infoButton.setPrimaryStyle()

        viewModel.infoShown.asObservable().map({ shown in return !shown}).bindTo(infoContainer.rx_hidden)
            .addDisposableTo(disposeBag)
        viewModel.infoTitle.asObservable().bindTo(infoTitle.rx_text).addDisposableTo(disposeBag)
        viewModel.infoSubtitle.asObservable().bindTo(infoSubtitle.rx_text).addDisposableTo(disposeBag)
        viewModel.infoButton.asObservable().bindTo(infoButton.rx_title).addDisposableTo(disposeBag)
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
        viewModel.imageSelected.asObservable().bindTo(selectedImage.rx_image).addDisposableTo(disposeBag)
        viewModel.postButtonEnabled.asObservable().bindTo(postButton.rx_enabled).addDisposableTo(disposeBag)

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
