//
//  UserRatingViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RateUserViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var rateInfoText: UILabel!
    @IBOutlet var stars: [UIButton]!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var descriptionCharCounter: UILabel!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let descrPlaceholder = LGLocalizedString.userRatingReviewPlaceholder
    private let descrPlaceholderColor = UIColor.gray
    private static let sendButtonMargin: CGFloat = 15

    private let viewModel: RateUserViewModel
    private let keyboardHelper: KeyboardHelper
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(viewModel: RateUserViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance)
    }

    init(viewModel: RateUserViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        self.keyboardHelper = keyboardHelper
        let navbarStyle = NavBarBackgroundStyle.Custom(background:
            UIColor.listBackgroundColor.colorWithAlphaComponent(0.8).imageWithSize(CGSize(width: 1, height: 1)), shadow: UIImage())
        super.init(viewModel: viewModel, nibName: "RateUserViewController", navBarBackgroundStyle: navbarStyle)
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupRx()
    }


    // MARK: - Actions

    @IBAction func publishButtonPressed(sender: AnyObject) {
        viewModel.publishButtonPressed()
    }

    @IBAction func starHighlighted(sender: AnyObject) {
        guard let tag = (sender as? UIButton)?.tag else { return }
        stars.forEach{$0.highlighted = ($0.tag <= tag)}
    }

    @IBAction func starSelected(sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        viewModel.ratingStarPressed(button.tag)
    }

    dynamic private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    dynamic private func viewBackgroundTap() {
        descriptionText.resignFirstResponder()
    }

    // MARK: - Private methods

    private func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.listBackgroundColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain,
                                                           target: self, action: #selector(closeButtonPressed))

        setNavBarTitle(LGLocalizedString.userRatingTitle)

        userImage.layer.cornerRadius = userImage.width / 2
        if let avatar = viewModel.userAvatar {
            userImage.lg_setImageWithURL(avatar)
        }
        userNameText.text = viewModel.userName
        rateInfoText.text = viewModel.infoText
        descriptionText.layer.borderColor = UIColor.lineGray.CGColor
        descriptionText.layer.borderWidth = LGUIKitConstants.onePixelSize
        descriptionText.text = descrPlaceholder
        descriptionText.textColor = descrPlaceholderColor

        publishButton.setStyle(.Primary(fontSize: .Big))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewBackgroundTap))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupRx() {
        viewModel.isLoading.asObservable().bindNext { [weak self] loading in
            self?.publishButton.setTitle(loading ? nil : LGLocalizedString.userRatingReviewButton, forState: .Normal)
            loading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }.addDisposableTo(disposeBag)
        viewModel.sendEnabled.asObservable().bindTo(publishButton.rx_enabled).addDisposableTo(disposeBag)

        viewModel.descriptionCharLimit.asObservable().map { return String($0) }.bindTo(descriptionCharCounter.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.rating.asObservable().bindNext { [weak self] rating in
            self?.stars.forEach{$0.highlighted = ($0.tag <= rating)}
            self?.stars.forEach{$0.selected = ($0.tag == rating)}
        }.addDisposableTo(disposeBag)

        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard let scrollView = self?.scrollView, var buttonRect = self?.publishButton.frame else { return }
            scrollView.contentInset.bottom = scrollView.height - origin
            buttonRect.bottom = buttonRect.bottom + RateUserViewController.sendButtonMargin
            scrollView.scrollRectToVisible(buttonRect, animated: false)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - UserRatingViewModelDelegate

extension RateUserViewController: RateUserViewModelDelegate {

    func vmUpdateDescription(description: String?) {
        descriptionText.text = description
    }
}


// MARK: - Textfield handling

extension RateUserViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        // clear text view placeholder
        if textView.text == descrPlaceholder && textView.textColor ==  descrPlaceholderColor {
            textView.text = nil
            textView.textColor = UIColor.grayDark
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descrPlaceholder
            textView.textColor = descrPlaceholderColor
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text {
            let cleanReplacement = text.stringByRemovingEmoji()
            let finalText = (textViewText as NSString).stringByReplacingCharactersInRange(range, withString: cleanReplacement)
            if finalText != descrPlaceholder && textView.textColor != descrPlaceholderColor {
                viewModel.description.value = finalText.isEmpty ? nil : finalText
                if text.hasEmojis() {
                    //Forcing the new text (without emojis) by returning false
                    textView.text = finalText
                    return false
                }
            }
        }
        return true
    }
}
