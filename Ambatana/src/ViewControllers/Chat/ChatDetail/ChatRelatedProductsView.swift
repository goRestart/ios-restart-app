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
    func relatedProductsViewDidShow(view: ChatRelatedProductsView)
    func relatedProductsView(view: ChatRelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?)

}


class ChatRelatedProductsView: UIView {

    private static let relatedProductsHeigh: CGFloat = 100
    private static let elementsMargin: CGFloat = 10
    private static let itemsSpacing: CGFloat = 5

    let title = Variable<String>("")
    let productId = Variable<String?>(nil)
    let visibleHeight = Variable<CGFloat>(0)

    weak var delegate: ChatRelatedProductsViewDelegate?

    private var topConstraint: NSLayoutConstraint?
    private let infoLabel = UILabel()
    private let relatedProductsView = RelatedProductsView(productsDiameter: ChatRelatedProductsView.relatedProductsHeigh, frame: CGRect.zero)
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

    func setupOnTopOfView(sibling: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        guard let parentView = sibling.superview else { return }
        parentView.addSubview(self)
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Top, relatedBy:
            NSLayoutRelation.Equal, toItem: sibling, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal,
                                      toItem: sibling, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal,
                                       toItem: sibling, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        parentView.addConstraints([top,left,right])
        topConstraint = top
    }


    // MARK: - Private

    private func setup() {
        backgroundColor = UIColor.whiteColor()
        layer.borderWidth = LGUIKitConstants.onePixelSize
        layer.borderColor = UIColor.lineGray.CGColor

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
        let metrics = ["margin": ChatRelatedProductsView.elementsMargin, "relatedHeight": ChatRelatedProductsView.relatedProductsHeigh]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[infoLabel]-margin-|", options: [],
            metrics: metrics, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[relatedView]|", options: [], metrics: nil,
            views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-margin-[infoLabel]-margin-[relatedView(relatedHeight)]-margin-|",
            options: [], metrics: metrics, views: views))
    }

    private func setupRx() {
        title.asObservable().bindTo(infoLabel.rx_text).addDisposableTo(disposeBag)
        visible.asObservable().map{!$0}.bindTo(self.rx_hidden).addDisposableTo(disposeBag)
        visible.asObservable().map{ [weak self] in $0 ? self?.height ?? 0 : 0 }.bindTo(visibleHeight).addDisposableTo(disposeBag)
        productId.asObservable().bindTo(relatedProductsView.productId).addDisposableTo(disposeBag)
        relatedProductsView.hasProducts.asObservable().bindNext { [weak self] hasProducts in
            self?.animateToVisible(hasProducts)
        }.addDisposableTo(disposeBag)
    }

    private func animateToVisible(visible: Bool) {
        self.visible.value = visible
        topConstraint?.constant = visible ? -height : 0
        UIView.animateWithDuration(0.3) { [weak self] in
            self?.superview?.layoutIfNeeded()
        }
        if visible {
            delegate?.relatedProductsViewDidShow(self)
        }
    }
}


extension ChatRelatedProductsView: RelatedProductsViewDelegate {
    func relatedProductsView(view: RelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {

        var realFrame: CGRect? = nil
        if let originFrame = originFrame, parentView = superview {
            realFrame = convertRect(originFrame, toView: parentView)
        }

        delegate?.relatedProductsView(self, showProduct: product, atIndex: index, productListModels: productListModels,
                                      requester: requester, thumbnailImage: thumbnailImage, originFrame: realFrame)
    }
}
