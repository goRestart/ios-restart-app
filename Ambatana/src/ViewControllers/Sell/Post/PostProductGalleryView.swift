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
    func productGalleryDidSelectImages(_ images: [UIImage])
    func productGalleryRequestsScrollLock(_ lock: Bool)
    func productGalleryDidPressTakePhoto()
    func productGalleryShowActionSheet(_ cancelAction: UIAction, actions: [UIAction])
    func productGallerySelection(selection: ImageSelection)
    func productGallerySwitchToCamera()
}

enum MessageInfoType {
    case noMessage
    case noImages
    case wrongImage
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
    @IBOutlet weak var topRightButton: UIButton!

    fileprivate var albumButtonTick = UIImageView()

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
        get {
            return viewModel.visible.value
        }
        set {
            viewModel.visible.value = newValue
        }
    }
    
    var collectionViewBottomInset: CGFloat {
        get {
            return collectionView.contentInset.bottom
        }
        set {
            collectionView.contentInset.bottom = newValue
        }
    }
    
    var usePhotoButtonText: String? {
        get {
            return topRightButton?.title(for: .normal)
        }
        set {
            topRightButton?.setTitle(newValue, for: .normal)
        }
    }
    private var headerShown = true

    // Drag & state vars
    var dragState: GalleryDragState = .none
    var initialDragPosition: CGFloat = 0
    var collapsed = false

    fileprivate var viewModel: PostListingGalleryViewModel

    fileprivate var disposeBag = DisposeBag()

    // MARK: - Lifecycle

    convenience init() {
        let viewModel = PostListingGalleryViewModel()
        self.init(viewModel: viewModel, frame: CGRect.zero)
    }

    init(viewModel: PostListingGalleryViewModel,
         frame: CGRect) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, frame: frame)
        self.viewModel.delegate = self
        setupUI()
    }

    init?(viewModel: PostListingGalleryViewModel,
          coder aDecoder: NSCoder) {
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

    func showHeader(_ show: Bool) {
        guard headerShown != show else { return }
        headerShown = show
        let destinationAlpha: CGFloat = show ? 1.0 : 0.0
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.headerContainer.alpha = destinationAlpha
        }) 
    }

    // MARK: - Actions

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        delegate?.productGalleryCloseButton()
    }
   
    dynamic func postButtonPressed() {
        viewModel.postButtonPressed()
    }
    
    @IBAction func topRightButtonPressed(_ sender: AnyObject) {
        postButtonPressed()
    }


    // MARK: - Private methods

    private func setupUI() {
        Bundle.main.loadNibNamed("PostProductGalleryView", owner: self, options: nil)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)

        topRightButton.setStyle(.primary(fontSize: .small))
        let cellNib = UINib(nibName: GalleryImageCell.reusableID, bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: GalleryImageCell.reusableID)
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 4.0
        }

        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.black, alphas:[0.4,0.0],
            locations: [0.0,1.0])
        shadowLayer.frame = collectionGradientView.bounds
        collectionGradientView.layer.addSublayer(shadowLayer)

        infoButton.setStyle(.primary(fontSize: .medium))

        configMessageView(.noMessage)

        setAccesibilityIds()
        setupRX()
        setupAlbumSelection()
    }

    fileprivate func configMessageView(_ type: MessageInfoType) {
        var title: String
        var subtitle: String
        switch type {
        case .noMessage:
            title = ""
            subtitle = ""
        case .noImages:
            title = LGLocalizedString.productPostGallerySelectPicturesTitle
            subtitle = LGLocalizedString.productPostGallerySelectPicturesSubtitle
        case .wrongImage:
            title = LGLocalizedString.productPostGalleryLoadImageErrorTitle
            subtitle = LGLocalizedString.productPostGalleryLoadImageErrorSubtitle
        }
        loadImageErrorTitleLabel.text = title
        loadImageErrorSubtitleLabel.text = subtitle
    }
    
    fileprivate func updateTopRightButton(state: GalleryState) {
        switch state {
        case .empty, .pendingAskPermissions, .missingPermissions, .loading:
            topRightButton.isEnabled = false
        case .normal, .loadImageError:
            topRightButton.isEnabled = viewModel.imagesSelectedCount != 0
        }
    }
}


// MARK: - PostProductGalleryViewDelegate

extension PostProductGalleryView: PostListingGalleryViewModelDelegate {

    func vmDidUpdateGallery() {
        collectionView.reloadData()
    }

    func vmDidSelectItemAtIndex(_ index: Int, shouldScroll: Bool) {
        animateToState(collapsed: false) { [weak self] in
            self?.selectItemAtIndex(index)
        }
    }

    func vmDidDeselectItemAtIndex(_ index: Int) {
        animateToState(collapsed: false) { [weak self] in
            self?.deselectItemAtIndex(index)
        }
    }

    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        delegate?.productGalleryShowActionSheet(cancelAction, actions: actions)
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PostProductGalleryView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imagesCount
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            return viewModel.cellSize
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            guard let galleryCell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryImageCell.reusableID,
                                                                       for: indexPath) as? GalleryImageCell else { return UICollectionViewCell() }
            
            galleryCell.tag = indexPath.row
            viewModel.imageForCellAtIndex(indexPath.row) { image in
                guard galleryCell.tag == indexPath.row else { return }
                galleryCell.image.image = image
            }
            let selectedIndexes: [Int] = viewModel.imagesSelected.value.map { $0.index }
            if selectedIndexes.contains(indexPath.item) {
                galleryCell.disabled = false
                galleryCell.isSelected = true
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
                if let position = selectedIndexes.index(of: indexPath.item) {
                    galleryCell.multipleSelectionCountLabel.text = "\(position + 1)"
                }
            } else if viewModel.imagesSelectedCount >= viewModel.maxImagesSelected {
                galleryCell.disabled = true
                galleryCell.isSelected = false
            } else {
                galleryCell.isSelected = false
                galleryCell.disabled = false
            }
            return galleryCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.imageSelectedAtIndex(indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return viewModel.imageSelectionEnabled.value
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.imageDeselectedAtIndex(indexPath.row)
    }

    fileprivate func selectItemAtIndex(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        if let layoutAttributes = layoutAttributes {
            collectionView.scrollRectToVisible(layoutAttributes.frame, animated: true)
        }
    }

    fileprivate func deselectItemAtIndex(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.deselectItem(at: indexPath, animated: false)
        let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        if let layoutAttributes = layoutAttributes {
            collectionView.scrollRectToVisible(layoutAttributes.frame, animated: true)
        }
    }
}


// MARK: - Info screen

extension PostProductGalleryView {

    fileprivate func setupRX() {
        viewModel.galleryState.asObservable().subscribeNext{ [weak self] state in
            guard let strongSelf = self else { return }
            self?.loadImageErrorView.isHidden = true
            self?.imageLoadActivityIndicator.stopAnimating()
            switch state {
            case .empty:
                strongSelf.infoTitle.text = LGLocalizedString.productPostEmptyGalleryTitle
                strongSelf.infoSubtitle.text = LGLocalizedString.productPostEmptyGallerySubtitle
                strongSelf.infoButton.setTitle(LGLocalizedString.productPostEmptyGalleryButton, for: .normal)
                strongSelf.infoContainer.isHidden = false
            case .pendingAskPermissions:
                strongSelf.infoTitle.text = LGLocalizedString.productPostGalleryPermissionsTitle
                strongSelf.infoSubtitle.text = LGLocalizedString.productPostGalleryPermissionsSubtitle
                strongSelf.infoButton.setTitle(LGLocalizedString.productPostGalleryPermissionsButton, for: .normal)
                strongSelf.infoContainer.isHidden = false
            case .missingPermissions(let msg):
                strongSelf.infoTitle.text = LGLocalizedString.productPostGalleryPermissionsTitle
                strongSelf.infoSubtitle.text = msg
                strongSelf.infoButton.setTitle(LGLocalizedString.productPostGalleryPermissionsButton, for: .normal)
                strongSelf.infoContainer.isHidden = false
            case .normal:
                strongSelf.infoContainer.isHidden = true
                // multi selection shows a "choose photos" text in loadImageErrorView at start instead of the 1st image
                strongSelf.topRightButton.isEnabled = strongSelf.viewModel.imagesSelectedCount != 0
                strongSelf.loadImageErrorView.isHidden = strongSelf.viewModel.imagesSelectedCount != 0
            case .loadImageError:
                strongSelf.infoContainer.isHidden = true
                strongSelf.loadImageErrorView.isHidden = (strongSelf.viewModel.imagesSelectedCount != 0)
                strongSelf.configMessageView(.wrongImage)
            case .loading:
                strongSelf.imageLoadActivityIndicator.startAnimating()
            }
            strongSelf.updateTopRightButton(state: state)
        }.addDisposableTo(disposeBag)

        viewModel.imagesSelected.asObservable().observeOn(MainScheduler.instance).bindNext { [weak self] imgsSelected in
            guard let strongSelf = self else { return }
            strongSelf.collectionView.isUserInteractionEnabled = false
            guard !strongSelf.viewModel.shouldUpdateDisabledCells else {
                self?.collectionView.reloadData()
                self?.collectionView.isUserInteractionEnabled = true
                return
            }
            var indexes: [IndexPath] = []
            for imgSel in imgsSelected {
                indexes.append(IndexPath(item: imgSel.index, section: 0))
            }

            UIView.performWithoutAnimation {
                strongSelf.collectionView.reloadItems(at: indexes)
            }
            if imgsSelected.count == 0 {
                strongSelf.configMessageView(.noImages)
                strongSelf.loadImageErrorView.isHidden = false
            } else {
                strongSelf.configMessageView(.noMessage)
                strongSelf.loadImageErrorView.isHidden = true
            }
            strongSelf.collectionView.isUserInteractionEnabled = true
        }.addDisposableTo(disposeBag)

        viewModel.imageSelection.distinctUntilChanged().bindNext { [weak self] selection in
            self?.delegate?.productGallerySelection(selection: selection)
        }.addDisposableTo(disposeBag)
    }

    @IBAction func onInfoButtonPressed(_ sender: AnyObject) {
        viewModel.infoButtonPressed()
    }
}


// MARK: - Album selection 

extension PostProductGalleryView {

    func setupAlbumSelection() {

        albumButtonTick.image = UIImage(named: "ic_down_triangle")?.withRenderingMode(.alwaysTemplate)
        albumButtonTick.tintColor = UIColor.white
        albumButtonTick.translatesAutoresizingMaskIntoConstraints = false
        albumButton.addSubview(albumButtonTick)
        let left = NSLayoutConstraint(item: albumButtonTick, attribute: .left, relatedBy: .equal,
            toItem: albumButton.titleLabel, attribute: .right, multiplier: 1.0, constant: 8)
        let centerV = NSLayoutConstraint(item: albumButtonTick, attribute: .centerY, relatedBy: .equal,
            toItem: albumButton, attribute: .centerY, multiplier: 1.0, constant: 2)
        albumButton.addConstraints([left,centerV])


        viewModel.albumTitle.asObservable().bindTo(albumButton.rx.title).addDisposableTo(disposeBag)
        viewModel.albumButtonEnabled.asObservable().bindTo(albumButton.rx.isEnabled).addDisposableTo(disposeBag)
        viewModel.lastImageSelected.asObservable().bindTo(selectedImage.rx.image).addDisposableTo(disposeBag)

        viewModel.albumIconState.asObservable().subscribeNext{ [weak self] status in
            switch status{
            case .hidden:
                self?.albumButtonTick.isHidden = true
            case .down:
                self?.albumButtonTick.isHidden = false
                self?.animateAlbumTickDirectionTop(false)
            case .up:
                self?.albumButtonTick.isHidden = false
                self?.animateAlbumTickDirectionTop(true)
            }
        }.addDisposableTo(disposeBag)
    }

    @IBAction func albumButtonPressed(_ sender: AnyObject) {
        viewModel.albumButtonPressed()
    }

    private func animateAlbumTickDirectionTop(_ top: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.albumButtonTick.transform = CGAffineTransform(rotationAngle: top ? CGFloat(Double.pi) : 0)
        })
    }
}


// MARK: - Dragging

enum GalleryDragState {
    case none, draggingCollection(Bool), draggingImage
}

extension PostProductGalleryView: UIGestureRecognizerDelegate {

    var imageContainerMaxHeight: CGFloat {
        return imageContainer.height-headerContainer.height
    }

    var imageContainerStateThreshold: CGFloat {
        return 50
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panRecognizer.velocity(in: contentView)
        let panningVertically = fabs(velocity.y) > fabs(velocity.x)
        return panningVertically
    }

    @IBAction func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: contentView)

        switch recognizer.state {
        case .began:
            if location.y < imageContainer.height+imageContainerTop.constant {
                dragState = .draggingImage
            } else {
                dragState = .draggingCollection(false)
            }
            initialDragPosition = imageContainerTop.constant
            delegate?.productGalleryRequestsScrollLock(true)
        case .ended:
            dragState = .none
            collectionView.isUserInteractionEnabled = true
            finishAnimating()
            delegate?.productGalleryRequestsScrollLock(false)
        default:
            handleDrag(recognizer)
        }
    }

    private func handleDrag(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: contentView)
        let translation = recognizer.translation(in: contentView)
        switch dragState {
        case .draggingImage:
            imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
            syncCollectionWithImage()
        case .draggingCollection(let fromTop):
            if location.y < imageContainer.height+imageContainerTop.constant {
                imageContainerTop.constant = max(min(0, -(imageContainer.height-20-location.y)), -imageContainerMaxHeight)
                syncCollectionWithImage()
                collectionView.isUserInteractionEnabled = false
            } else if (imageContainerTop.constant < 0) && (collectionView.contentOffset.y <= 0 || fromTop) {
                imageContainerTop.constant = max(min(0, initialDragPosition + translation.y), -imageContainerMaxHeight)
                syncCollectionWithImage()
                dragState = .draggingCollection(true)
            } else if !fromTop {
                recognizer.setTranslation(CGPoint(x:0, y:0), in: contentView)
            }
        case .none:
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

    fileprivate func animateToState(collapsed: Bool, completion: (() -> Void)?) {
        let hasChanges = collapsed != self.collapsed
        imageContainerTop.constant = collapsed ? -imageContainerMaxHeight : 0
        self.collapsed = collapsed

        UIView.animate(withDuration: 0.2,
            animations: { [weak self] in
                self?.syncCollectionWithImage()
                if hasChanges {
                    self?.contentView.layoutIfNeeded()
                }
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
        closeButton.accessibilityId = .postingGalleryCloseButton
        imageContainer.accessibilityId = .postingGalleryImageContainer
        imageLoadActivityIndicator.accessibilityId = .postingGalleryLoading
        collectionView.accessibilityId = .postingGalleryCollection
        albumButton.accessibilityId = .postingGalleryAlbumButton
        topRightButton.accessibilityId = .postingGalleryUsePhotoButton
        infoButton.accessibilityId = .postingGalleryInfoScreenButton
    }
}
