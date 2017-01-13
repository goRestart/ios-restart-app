//
//  ChatRelatedProductsView.swift
//  LetGo
//
//  Created by Eli Kohen on 23/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import RxCocoa


protocol ChatRelatedProductsViewDelegate: class {
    func relatedProductsViewDidShow(_ view: ChatRelatedProductsView)
    func relatedProductsView(_ view: ChatRelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?)

}


class ChatRelatedProductsView: UIView {

    private static let defaultWidth = UIScreen.main.bounds.width
    private static let relatedProductsHeight: CGFloat = 100
    private static let elementsMargin: CGFloat = 10
    private static let itemsSpacing: CGFloat = 5

    let title = Variable<String>("")
    let productId = Variable<String?>(nil)
    let visibleHeight = Variable<CGFloat>(0)

    weak var delegate: ChatRelatedProductsViewDelegate?

    private var topConstraint: NSLayoutConstraint?
    private let infoLabel = UILabel()
    private let relatedProductsView = RelatedProductsView(productsDiameter: ChatRelatedProductsView.relatedProductsHeight,
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
                       width: ChatRelatedProductsView.defaultWidth, height: ChatRelatedProductsView.relatedProductsHeight)
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

        relatedProductsView.delegate = self
        relatedProductsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(relatedProductsView)

        setupConstraints()
        setupRx()
    }

    private func setupConstraints() {
        let views = ["infoLabel": infoLabel, "relatedView": relatedProductsView]
        let metrics = ["margin": ChatRelatedProductsView.elementsMargin, "relatedHeight": ChatRelatedProductsView.relatedProductsHeight]
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[infoLabel]-margin-|", options: [],
            metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[relatedView]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-margin-[infoLabel]-margin-[relatedView(relatedHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
    }

    private func setupRx() {
        title.asObservable().bindTo(infoLabel.rx.text).addDisposableTo(disposeBag)
        visible.asObservable().map{!$0}.bindTo(self.rx.isHidden).addDisposableTo(disposeBag)
        visible.asObservable().map{ [weak self] in $0 ? self?.height ?? 0 : 0 }.bindTo(visibleHeight).addDisposableTo(disposeBag)
        productId.asObservable().bindTo(relatedProductsView.productId).addDisposableTo(disposeBag)
        relatedProductsView.hasProducts.asObservable().bindNext { [weak self] hasProducts in
            self?.animateToVisible(hasProducts)
        }.addDisposableTo(disposeBag)
    }

    private func animateToVisible(_ visible: Bool) {
        self.visible.value = visible
        topConstraint?.constant = visible ? -height : 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.superview?.layoutIfNeeded()
        }) 
        if visible {
            delegate?.relatedProductsViewDidShow(self)
        }
    }
}


extension ChatRelatedProductsView: RelatedProductsViewDelegate {
    func relatedProductsView(_ view: RelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {

        var realFrame: CGRect? = nil
        if let originFrame = originFrame, let parentView = superview {
            realFrame = convert(originFrame, to: parentView)
        }

        delegate?.relatedProductsView(self, showProduct: product, atIndex: index, productListModels: productListModels,
                                      requester: requester, thumbnailImage: thumbnailImage, originFrame: realFrame)
    }
}
