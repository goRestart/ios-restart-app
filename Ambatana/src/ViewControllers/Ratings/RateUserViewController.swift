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
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var descriptionCharCounter: UILabel!
    @IBOutlet weak var descriptionInfoLabel: UILabel!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var descrPlaceholder = LGLocalizedString.userRatingReviewPlaceholder
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
        super.init(viewModel: viewModel, nibName: "RateUserViewController",
                   navBarBackgroundStyle: .transparent(substyle: .light))
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAccesibilityIds()
        setupRx()
    }


    // MARK: - Actions

    @IBAction func publishButtonPressed(_ sender: AnyObject) {
        viewModel.publishButtonPressed()
    }

    @IBAction func starHighlighted(_ sender: AnyObject) {
        guard let tag = (sender as? UIButton)?.tag else { return }
        stars.forEach{$0.isHighlighted = ($0.tag <= tag)}
        viewBackgroundTap()
    }

    @IBAction func starSelected(_ sender: AnyObject) {
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain,
                                                           target: self, action: #selector(closeButtonPressed))

        setNavBarTitle(LGLocalizedString.userRatingTitle)

        userImage.layer.cornerRadius = userImage.width / 2
        if let avatar = viewModel.userAvatar {
            userImage.lg_setImageWithURL(avatar)
        }
        userNameText.text = viewModel.userName
        rateInfoText.text = viewModel.infoText
        descriptionContainer.layer.borderColor = UIColor.lineGray.cgColor
        descriptionContainer.layer.borderWidth = LGUIKitConstants.onePixelSize
        descriptionText.text = descrPlaceholder
        descriptionText.textColor = descrPlaceholderColor
        descriptionInfoLabel.text = LGLocalizedString.userRatingReviewInfo

        publishButton.setStyle(.primary(fontSize: .big))

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewBackgroundTap))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupRx() {
        viewModel.isLoading.asObservable().bindNext { [weak self] loading in
            self?.publishButton.setTitle(loading ? nil : LGLocalizedString.userRatingReviewButton, for: .normal)
            loading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
        }.addDisposableTo(disposeBag)
        viewModel.sendEnabled.asObservable().bindTo(publishButton.rx.isEnabled).addDisposableTo(disposeBag)

        viewModel.descriptionCharLimit.asObservable().map { return String($0) }.bindTo(descriptionCharCounter.rx_text)
            .addDisposableTo(disposeBag)

        viewModel.rating.asObservable().bindNext { [weak self] rating in
            onMainThread { [weak self] in
                self?.stars.forEach{$0.isHighlighted = ($0.tag <= rating!)}
            }
        }.addDisposableTo(disposeBag)

        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard let scrollView = self?.scrollView, var buttonRect = self?.publishButton.frame,
                let topHeight = self?.topBarHeight else { return }
            scrollView.contentInset.bottom = scrollView.height - origin + topHeight
            buttonRect.bottom = buttonRect.bottom + RateUserViewController.sendButtonMargin
            scrollView.scrollRectToVisible(buttonRect, animated: false)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - UserRatingViewModelDelegate

extension RateUserViewController: RateUserViewModelDelegate {

    func vmUpdateDescription(_ description: String?) {
        setDescription(description)
    }

    func vmUpdateDescriptionPlaceholder(_ placeholder: String) {
        guard let descriptionText = descriptionText else { return }
        guard placeholder != descrPlaceholder else { return }
        if descriptionText.text == descrPlaceholder {
            descriptionText.text = placeholder
        }
        descrPlaceholder = placeholder
    }
}


// MARK: - Textfield handling

extension RateUserViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // clear text view placeholder
        if textView.text == descrPlaceholder && textView.textColor ==  descrPlaceholderColor {
            textView.text = nil
            textView.textColor = UIColor.grayDark
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = descrPlaceholder
            textView.textColor = descrPlaceholderColor
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text else { return true }
        guard textViewText.characters.count + (text.characters.count - range.length) <= Constants.userRatingDescriptionMaxLength else { return false }
        let cleanReplacement = text.stringByRemovingEmoji()
        let finalText = (textViewText as NSString).replacingCharacters(in: range, with: cleanReplacement)
        if finalText != descrPlaceholder && textView.textColor != descrPlaceholderColor {
            viewModel.description.value = finalText.isEmpty ? nil : finalText
            if text.hasEmojis() {
                //Forcing the new text (without emojis) by returning false
                setDescription(finalText)
                return false
            }
        }
        return true
    }

    private func setDescription(_ description: String?) {
        if let description = description, !description.isEmpty {
            descriptionText.text = description
            descriptionText.textColor = UIColor.grayDark
        } else {
            descriptionText.text = descrPlaceholder
            descriptionText.textColor = descrPlaceholderColor
        }
    }
}


// MARK: - Accesibility

extension RateUserViewController {
    func setAccesibilityIds() {
        userNameText.accessibilityId = .rateUserUserNameLabel
        if stars.count == 5 {
            stars[0].accessibilityId = .rateUserStarButton1
            stars[1].accessibilityId = .rateUserStarButton2
            stars[2].accessibilityId = .rateUserStarButton3
            stars[3].accessibilityId = .rateUserStarButton4
            stars[4].accessibilityId = .rateUserStarButton5
        }
        descriptionText.accessibilityId = .rateUserDescriptionField
        activityIndicator.accessibilityId = .rateUserLoading
        publishButton.accessibilityId = .rateUserPublishButton
    }
}
