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
    @IBOutlet weak var textBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    fileprivate let viewModel: ReportUsersViewModel

    fileprivate static let textBottomSpace: CGFloat = 76
    fileprivate var cellSize: CGSize = CGSize(width: 160.0, height: 150.0)
    fileprivate var isCommentPlaceholder: Bool {
        return commentTextView.text == LGLocalizedString.reportUserTextPlaceholder &&
            commentTextView.textColor == UIColor.grayPlaceholderText
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
        hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAccesibilityIds()

        NotificationCenter.default.addObserver(self, selector: #selector(ReportUsersViewController.keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReportUsersViewController.keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }


    // MARK: - Actions

    @IBAction func onSendButton(_ sender: AnyObject) {
        commentTextView.resignFirstResponder()
        viewModel.sendReport(comment)
    }


    // MARK: - ReportUsersViewModelDelegate

    func reportUsersViewModelDidUpdateReasons(_ viewModel: ReportUsersViewModel) {
        collectionView.reloadData()
        sendButton.isEnabled = viewModel.saveButtonEnabled
    }

    func reportUsersViewModelDidStartSendingReport(_ viewModel: ReportUsersViewModel) {
        showLoadingMessageAlert()
    }

    func reportUsersViewModel(_ viewModel: ReportUsersViewModel, didSendReport successMsg: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(successMsg) { [weak self] in
                self?.popViewController(animated: true, completion: nil)
            }
        }
    }

    func reportUsersViewModel(_ viewModel: ReportUsersViewModel, failedSendingReport errorMsg: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(errorMsg)
        }
    }


    // MARK: - Private methods

    private func setupUI() {
        ReportUserCellDrawer.registerCell(collectionView)

        sendButton.setStyle(.primary(fontSize: .medium))
        sendButton.setTitle(LGLocalizedString.reportUserSendButton, for: UIControlState())
        sendButton.isEnabled = false

        commentTextView.text = LGLocalizedString.reportUserTextPlaceholder
        commentTextView.textColor = UIColor.grayPlaceholderText

        let cellWidth = UIScreen.main.bounds.size.width * 0.33 //3 columns
        cellSize = CGSize(width: cellWidth, height: 140)

        setNavBarTitle(LGLocalizedString.reportUserTitle)
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ReportUsersViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reportReasonsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellDrawer = ReportUserCellDrawer()
        let cell = cellDrawer.cell(collectionView, atIndexPath: indexPath)
        let image = viewModel.imageForReasonAtIndex(indexPath.row)
        let text = viewModel.textForReasonAtIndex(indexPath.row)
        let selected = viewModel.isReasonSelectedAtIndex(indexPath.row)
        cellDrawer.draw(cell, image: image, text: text, selected: selected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        commentTextView.resignFirstResponder()
        viewModel.selectedReasonAtIndex(indexPath.row)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        commentTextView.resignFirstResponder()
    }
}


// MARK: - UITextViewDelegate

extension ReportUsersViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isCommentPlaceholder {
            textView.text = nil
            textView.textColor = UIColor.blackText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = LGLocalizedString.reportUserTextPlaceholder
            textView.textColor = UIColor.grayPlaceholderText
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            onSendButton(textView)
            return false
        }
        return true
    }
}


// MARK: - Keyboard handling

extension ReportUsersViewController {

    func keyboardWillShow(_ notification: Notification) {
        moveBottomForKeyboard(notification, showing: true)
    }

    func keyboardWillHide(_ notification: Notification) {
        moveBottomForKeyboard(notification, showing: false)
    }

    func moveBottomForKeyboard(_ keyboardNotification: Notification, showing: Bool) {
        let kbChange = keyboardNotification.keyboardChange
        textBottomConstraint.constant = showing ? kbChange.height : ReportUsersViewController.textBottomSpace
        bottomConstraint.constant = showing ? kbChange.height - ReportUsersViewController.textBottomSpace : 0
        UIView.animate(withDuration: TimeInterval(kbChange.animationTime), delay: 0, options: kbChange.animationOptions,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: { [weak self] completed in
                self?.scrollCollectionToSelected()
            }
        )
    }

    func scrollCollectionToSelected() {
        guard let selectedIndex = viewModel.selectedReasonIndex else { return }
        collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0),
            at: UICollectionViewScrollPosition.top, animated: true)
    }
}


// MARK: - Accesibility

extension ReportUsersViewController {
    func setAccesibilityIds() {
        collectionView.accessibilityId = .reportUserCollection
        commentTextView.accessibilityId = .reportUserCommentField
        sendButton.accessibilityId = .reportUserSendButton
    }
}
