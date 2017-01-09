//
//  ExpressChatViewController.swift
//  LetGo
//
//  Created by Dídac on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class ExpressChatViewController: BaseViewController {

    static let collectionCellIdentifier = "ExpressChatCell"
    static let cellSeparation: CGFloat = 10
    static let collectionHeight: CGFloat = 250
    static let marginForButtonToKeyboard: CGFloat = 15

    var viewModel: ExpressChatViewModel

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dontMissLabel: UILabel!
    @IBOutlet weak var contactSellersLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var dontAskAgainButton: UIButton!

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    let disposeBag = DisposeBag()

    convenience init(viewModel: ExpressChatViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance)
    }

    init (viewModel: ExpressChatViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ExpressChatViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRX()
        setupAccessibilityIds()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
    }

    func setupUI() {
        view.backgroundColor = UIColor.grayBackground
        scrollView.backgroundColor = UIColor.clear
        automaticallyAdjustsScrollViewInsets = false

        dontMissLabel.text = LGLocalizedString.chatExpressDontMissLabel.uppercased()
        contactSellersLabel.text = LGLocalizedString.chatExpressContactSellersLabel

        sendMessageButton.setStyle(.primary(fontSize: .big))
        
        dontAskAgainButton.setTitle(LGLocalizedString.chatExpressDontAskAgainButton.uppercased(), for: UIControlState())
        dontAskAgainButton.setTitleColor(UIColor.grayText, for: UIControlState())
        dontAskAgainButton.titleLabel?.font = UIFont.mediumBodyFont

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewHeightConstraint.constant = viewModel.productListCount > 2 ?
            ExpressChatViewController.collectionHeight : ExpressChatViewController.collectionHeight/2
        let cellNib = UINib(nibName: "ExpressChatCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: ExpressChatViewController.collectionCellIdentifier)
        collectionView.allowsMultipleSelection = true

        for i in 0...viewModel.productListCount {
            collectionView.selectItem(at: IndexPath(item: i, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }

    func setupRX() {
        viewModel.sendMessageTitle.asObservable().bindTo(sendMessageButton.rx_title).addDisposableTo(disposeBag)
        viewModel.sendButtonEnabled.asObservable().bindTo(sendMessageButton.rx.isEnabled).addDisposableTo(disposeBag)
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeExpressChat(true)
    }

    @IBAction func sendMessageButtonPressed(_ sender: AnyObject) {
        viewModel.sendMessage()
    }

    @IBAction func dontAskAgainButtonPressed(_ sender: AnyObject) {
        viewModel.closeExpressChat(false)
    }
}


extension ExpressChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = (UIScreen.main.bounds.width - (ExpressChatViewController.cellSeparation*3))/2
        return CGSize(width: cellSize, height: cellSize)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.productListCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: ExpressChatViewController.collectionCellIdentifier,
                                                    for: indexPath) as? ExpressChatCell else {
                                                        return UICollectionViewCell()
        }
        let title = viewModel.titleForItemAtIndex(indexPath.item)
        let imageURL = viewModel.imageURLForItemAtIndex(indexPath.item)
        let price = viewModel.priceForItemAtIndex(indexPath.item)
        cell.configureCellWithTitle(title, imageUrl: imageURL, price: price)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItemAtIndex(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.deselectItemAtIndex(indexPath.item)
    }
}


extension ExpressChatViewController: ExpressChatViewModelDelegate {
    func sendMessageSuccess() {

    }
}


extension ExpressChatViewController {
    func setupAccessibilityIds() {
        self.closeButton.accessibilityId = .expressChatCloseButton
        self.collectionView.accessibilityId = .expressChatCollection
        self.sendMessageButton.accessibilityId = .expressChatSendButton
        self.dontAskAgainButton.accessibilityId = .expressChatDontAskButton
   }
}
