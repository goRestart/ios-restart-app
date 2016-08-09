//
//  ExpressChatViewController.swift
//  LetGo
//
//  Created by Dídac on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ExpressChatViewController: BaseViewController {

    static let collectionCellIdentifier = "ExpressChatCell"

    var viewModel: ExpressChatViewModel

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dontMissLabel: UILabel!
    @IBOutlet weak var contactSellersLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var dontAskAgainButton: UIButton!


    init(viewModel: ExpressChatViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ExpressChatViewController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self

        dontMissLabel.text = ""
        contactSellersLabel.text = ""

        messageTextField.text = ""

        sendMessageButton.setStyle(.Primary(fontSize: .Big))
        dontAskAgainButton.setTitle("", forState: .Normal)
        dontAskAgainButton.setTitleColor(UIColor.grayText, forState: .Normal)
        dontAskAgainButton.titleLabel?.font = UIFont.mediumBodyFont
    }


}

extension ExpressChatViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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

    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

    }
}