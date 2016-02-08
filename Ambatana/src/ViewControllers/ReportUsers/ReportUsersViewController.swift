//
//  ReportUsersViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 05/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ReportUsersViewController: BaseViewController, ReportUsersViewModelDelegate {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    private let viewModel: ReportUsersViewModel

    private var cellSize: CGSize = CGSize(width: 160.0, height: 150.0)
    private var isCommentPlaceholder: Bool {
        return commentTextView.text == LGLocalizedString.reportUserTextPlaceholder &&
            commentTextView.textColor == StyleHelper.reportPlaceholderColor
    }

    private var comment: String? {
        guard !isCommentPlaceholder else { return nil }
        return commentTextView.text
    }


    // MARK: - Lifecycle

    init(viewModel: ReportUsersViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "ReportUsersViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
    }


    // MARK: - Actions

    @IBAction func onSendButton(sender: AnyObject) {
        viewModel.sendReport(comment)
    }


    // MARK: - ReportUsersViewModelDelegate

    func reportUsersViewModelDidUpdateReasons(viewModel: ReportUsersViewModel) {
        collectionView.reloadData()
        sendButton.enabled = viewModel.saveButtonEnabled
    }

    func reportUsersViewModelDidStartSendingReport(viewModel: ReportUsersViewModel) {
        showLoadingMessageAlert()
    }

    func reportUsersViewModel(viewModel: ReportUsersViewModel, didSendReport successMsg: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(successMsg) { [weak self] in
                self?.popViewController(animated: true, completion: nil)
            }
        }
    }

    func reportUsersViewModel(viewModel: ReportUsersViewModel, failedSendingReport errorMsg: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(errorMsg)
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        ReportUserCellDrawer.registerCell(collectionView)

        sendButton.setPrimaryStyle()
        sendButton.setTitle(LGLocalizedString.reportUserSendButton, forState: UIControlState.Normal)
        sendButton.enabled = false

        commentTextView.text = LGLocalizedString.reportUserTextPlaceholder
        commentTextView.textColor = StyleHelper.reportPlaceholderColor

        let cellWidth = UIScreen.mainScreen().bounds.size.width * 0.33 //3 columns
        cellSize = CGSizeMake(cellWidth, 140)

        setLetGoNavigationBarStyle(LGLocalizedString.reportUserTitle)
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ReportUsersViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reportReasonsCount
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellDrawer = ReportUserCellDrawer()
        let cell = cellDrawer.cell(collectionView, atIndexPath: indexPath)
        let image = viewModel.imageForReasonAtIndex(indexPath.row)
        let text = viewModel.textForReasonAtIndex(indexPath.row)
        let selected = viewModel.isReasonSelectedAtIndex(indexPath.row)
        cellDrawer.draw(cell, image: image, text: text, selected: selected)
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        commentTextView.resignFirstResponder()
        viewModel.selectedReasonAtIndex(indexPath.row)
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        commentTextView.resignFirstResponder()
    }
}


// MARK: - UITextViewDelegate

extension ReportUsersViewController: UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        if isCommentPlaceholder {
            textView.text = nil
            textView.textColor = StyleHelper.reportTextColor
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = LGLocalizedString.reportUserTextPlaceholder
            textView.textColor = StyleHelper.reportPlaceholderColor
        }
    }
}


// MARK: - Keyboard handling

extension ReportUsersViewController {

    func keyboardWillShow(notification: NSNotification) {
        moveBottomForKeyboard(notification, showing: true)
    }

    func keyboardWillHide(notification: NSNotification) {
        moveBottomForKeyboard(notification, showing: false)
    }

    func moveBottomForKeyboard(keyboardNotification: NSNotification, showing: Bool) {
        let kbAnimation = KeyboardAnimation(keyboardNotification: keyboardNotification)
        bottomConstraint.constant = showing ? kbAnimation.size.height : 0
        UIView.animateWithDuration(kbAnimation.duration, delay: 0, options: kbAnimation.options,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: { [weak self] completed in
                self?.scrollCollectionToSelected()
            }
        )
    }

    func scrollCollectionToSelected() {
        guard let selectedIndex = viewModel.selectedReasonIndex else { return }
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0),
            atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
    }
}
