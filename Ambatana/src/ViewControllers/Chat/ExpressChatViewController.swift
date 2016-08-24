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
    static let collectionHeight: CGFloat = 250
    static let marginForButtonToKeyboard: CGFloat = 15

    var viewModel: ExpressChatViewModel
    var keyboardHelper: KeyboardHelper

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dontMissLabel: UILabel!
    @IBOutlet weak var contactSellersLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var dontAskAgainButton: UIButton!

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    let disposeBag = DisposeBag()

    convenience init(viewModel: ExpressChatViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance)
    }

    init (viewModel: ExpressChatViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        self.keyboardHelper = keyboardHelper
        super.init(viewModel: viewModel, nibName: "ExpressChatViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRX()
    }

    override func viewDidFirstLayoutSubviews() {
        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard let viewHeight = self?.view.height where viewHeight >= origin else { return }
            guard let scrollView = self?.scrollView, var buttonRect = self?.sendMessageButton.frame else { return }
            scrollView.contentInset.bottom = viewHeight - origin
            buttonRect.bottom = buttonRect.bottom + ExpressChatViewController.marginForButtonToKeyboard
            scrollView.scrollRectToVisible(buttonRect, animated: false)
            }.addDisposableTo(disposeBag)
    }

    func setupUI() {
        view.backgroundColor = UIColor.grayBackground
        scrollView.backgroundColor = UIColor.clearColor()
        automaticallyAdjustsScrollViewInsets = false

        dontMissLabel.text = LGLocalizedString.chatExpressDontMissLabel
        contactSellersLabel.text = LGLocalizedString.chatExpressContactSellersLabel

        textFieldContainer.layer.cornerRadius = LGUIKitConstants.tooltipCornerRadius
        
        messageTextField.text = viewModel.messageText.value
        messageTextField.delegate = self
        messageTextField.tintColor = UIColor.primaryColor
        
        sendMessageButton.setStyle(.Primary(fontSize: .Big))
        
        dontAskAgainButton.setTitle(LGLocalizedString.chatExpressDontAskAgainButton, forState: .Normal)
        dontAskAgainButton.setTitleColor(UIColor.grayText, forState: .Normal)
        dontAskAgainButton.titleLabel?.font = UIFont.mediumBodyFont

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionViewHeightConstraint.constant = viewModel.productListCount > 2 ?
            ExpressChatViewController.collectionHeight : ExpressChatViewController.collectionHeight/2
        let cellNib = UINib(nibName: "ExpressChatCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: ExpressChatViewController.collectionCellIdentifier)
        collectionView.allowsMultipleSelection = true

        for i in 0...viewModel.productListCount {
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0), animated: false, scrollPosition: .None)
        }
    }

    func setupRX() {
        viewModel.sendMessageTitle.asObservable().bindTo(sendMessageButton.rx_title).addDisposableTo(disposeBag)
        viewModel.sendButtonEnabled.asObservable().bindTo(sendMessageButton.rx_enabled).addDisposableTo(disposeBag)
    }

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeExpressChat(true)
    }

    @IBAction func sendMessageButtonPressed(sender: AnyObject) {
        viewModel.sendMessage()
    }

    @IBAction func dontAskAgainButtonPressed(sender: AnyObject) {
        viewModel.closeExpressChat(false)
    }
}

extension ExpressChatViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let updatedText =  (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        viewModel.textFieldUpdatedWithText(updatedText)
        return true
    }
}

extension ExpressChatViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.productListCount
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCellWithReuseIdentifier(ExpressChatViewController.collectionCellIdentifier,
                                                    forIndexPath: indexPath) as? ExpressChatCell else {
                                                        return UICollectionViewCell()
        }
        let imageURL = viewModel.imageURLForItemAtIndex(indexPath.item)
        let price = viewModel.priceForItemAtIndex(indexPath.item)
        cell.configureCellWithImage(imageURL, price: price)

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.selectItemAtIndex(indexPath.item)
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        viewModel.deselectItemAtIndex(indexPath.item)
    }
}


extension ExpressChatViewController: ExpressChatViewModelDelegate {
    func sendMessageSuccess() {

    }
}
