import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents

protocol ChatRelatedListingsViewDelegate: class {
    func relatedListingsViewDidShow(_ view: ChatRelatedListingsView)
    func relatedListingsView(_ view: ChatRelatedListingsView, showListing listing: Listing, atIndex index: Int,
                             listingListModels: [ListingCellModel], requester: ListingListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?)

}


class ChatRelatedListingsView: UIView {

    private static let defaultWidth = UIScreen.main.bounds.width
    private static let relatedListingsHeight: CGFloat = 100
    private static let elementsMargin: CGFloat = 10
    private static let itemsSpacing: CGFloat = 5

    let title = Variable<String>("")
    let listingId = Variable<String?>(nil)
    let visibleHeight = Variable<CGFloat>(0)

    weak var delegate: ChatRelatedListingsViewDelegate?

    private var topConstraint: NSLayoutConstraint?
    private let infoLabel = UILabel()
    private let relatedListingsView = RelatedListingsView(listingsDiameter: ChatRelatedListingsView.relatedListingsHeight,
                                                          frame: CGRect.zero)
    private let visible = Variable<Bool>(false)

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }


    // MARK: - Public

    func setupOnTopOfView(_ sibling: UIView) {
        frame = CGRect(x: 0, y: sibling.top,
                       width: ChatRelatedListingsView.defaultWidth, height: ChatRelatedListingsView.relatedListingsHeight)
        translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        parentView.insertSubview(self, belowSubview: sibling)
        let top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: sibling, attribute: .top,
                                     multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: sibling, attribute: .left,
                                      multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: sibling, attribute: .right,
                                       multiplier: 1, constant: 0)
        parentView.addConstraints([top,left,right])
        topConstraint = top
    }


    // MARK: - Private

    private func setup() {
        backgroundColor = UIColor.white
        layer.borderWidth = LGUIKitConstants.onePixelSize
        layer.borderColor = UIColor.lineGray.cgColor

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.grayDark
        infoLabel.font = UIFont.sectionTitleFont
        addSubview(infoLabel)

        relatedListingsView.delegate = self
        relatedListingsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(relatedListingsView)

        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        let views = ["infoLabel": infoLabel, "relatedView": relatedListingsView]
        let metrics = ["margin": ChatRelatedListingsView.elementsMargin, "relatedHeight": ChatRelatedListingsView.relatedListingsHeight]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[infoLabel]-margin-|", options: [],
            metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[relatedView]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-margin-[infoLabel]-margin-[relatedView(relatedHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
    }

    private func setupRx() {
        title.asObservable().bind(to: infoLabel.rx.text).disposed(by: disposeBag)
        visible.asObservable().map{!$0}.bind(to: self.rx.isHidden).disposed(by: disposeBag)
        visible.asObservable().map{ [weak self] in $0 ? self?.height ?? 0 : 0 }.bind(to: visibleHeight).disposed(by: disposeBag)
        listingId.asObservable().bind(to: relatedListingsView.listingId).disposed(by: disposeBag)
        relatedListingsView.hasListings.asObservable().bind { [weak self] hasListings in
            self?.animateToVisible(hasListings)
        }.disposed(by: disposeBag)
    }

    private func animateToVisible(_ visible: Bool) {
        self.visible.value = visible
        topConstraint?.constant = visible ? -height : 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.superview?.layoutIfNeeded()
        }) 
        if visible {
            delegate?.relatedListingsViewDidShow(self)
        }
    }
}


extension ChatRelatedListingsView: RelatedListingsViewDelegate {
    func relatedListingsView(_ view: RelatedListingsView, showListing listing: Listing, atIndex index: Int,
                             listingListModels: [ListingCellModel], requester: ListingListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {

        var realFrame: CGRect? = nil
        if let originFrame = originFrame, let parentView = superview {
            realFrame = convert(originFrame, to: parentView)
        }

        delegate?.relatedListingsView(self, showListing: listing, atIndex: index, listingListModels: listingListModels,
                                      requester: requester, thumbnailImage: thumbnailImage, originFrame: realFrame)
    }
}
