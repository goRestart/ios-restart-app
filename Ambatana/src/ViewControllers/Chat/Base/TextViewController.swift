//
//  TextViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import RxSwift

class TextViewController: KeyboardViewController {

    var viewMargins: CGFloat = 10
    var textViewMargin: CGFloat = 5

    var textMaxLines: UInt = 6
    var invertedTable = true {
        didSet {
            updateInverted()
        }
    }
    var textViewBarHidden = false {
        didSet {
            textViewBarMaxHeight.constant = textViewBarHidden ? 0 : maxTextViewBarHeight
        }
    }
    var textViewFont: UIFont = UIFont.systemFontOfSize(17) {
        didSet {
            textView.font = textViewFont
            fitTextView()
        }
    }

    let tableView = UITableView()
    var singleTapGesture: UITapGestureRecognizer?
    let textViewBar = UIView()
    let textView = KMPlaceholderTextView()
    let leftButtonsContainer = UIView()
    let sendButton = UIButton(type: .Custom)
    var leftActions: [UIAction] = [] {
        didSet {
            updateLeftActions()
        }
    }
    var textViewBarColor: UIColor? = nil {
        didSet {
            textViewBar.backgroundColor = textViewBarColor
        }
    }

    private let maxTextViewBarHeight: CGFloat = 1000
    private let textViewInsets: CGFloat = 7
    private var textViewBarMaxHeight = NSLayoutConstraint()
    private var textViewRightConstraint = NSLayoutConstraint()
    private var textViewHeight = NSLayoutConstraint()
    private var leftActionsDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()


    override init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .Default,
                  navBarBackgroundStyle: NavBarBackgroundStyle = .Default){
        super.init(viewModel: viewModel, nibName: nibNameOrNil, statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Public

    func setTextViewBarHidden(hidden: Bool, animated: Bool) {
        textViewBarHidden = hidden
        if animated {
            UIView.animateWithDuration(0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }

    func presentKeyboard(animated: Bool) {
        guard !textView.isFirstResponder() else { return }
        if !animated {
            UIView.performWithoutAnimation { [weak self] in
                self?.textView.becomeFirstResponder()
            }
        } else {
            textView.becomeFirstResponder()
        }
    }

    func dismissKeyboard(animated: Bool) {

        // Dismisses the keyboard from any first responder in the window.
        if !textView.isFirstResponder() && keyboardVisible {
            view.window?.endEditing(false)
        }

        if !animated {
            UIView.performWithoutAnimation { [weak self] in
                self?.textView.resignFirstResponder()
            }
        } else {
            textView.resignFirstResponder()
        }
    }


    // MARK: - Methods to override

    func sendButtonPressed() {

    }

    func keyForTextCaching() -> String? {
        return nil
    }


    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        setupTextArea()
        setupTable()
    }
}


// MARK: - Table

extension TextViewController: UITableViewDelegate, UITableViewDataSource {

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.fitHorzontallyToParent()
        tableView.alignParentTop()
        tableView.toTopOf(textViewBar)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        updateInverted()

        tableView.keyboardDismissMode = .OnDrag
        tableView.delegate = self
        tableView.dataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTap))
        tapGesture.requireGestureRecognizerToFail(tableView.panGestureRecognizer)
        tableView.addGestureRecognizer(tapGesture)
        singleTapGesture = tapGesture
    }

    private func updateInverted() {
        tableView.transform = invertedTable ? CGAffineTransformMake(1, 0, 0, -1, 0, 0) : CGAffineTransformIdentity;
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    dynamic private func scrollViewTap() {
        dismissKeyboard(true)
    }
}


// MARK: - TextArea

extension TextViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    private func setupTextArea() {
        // Set textview font parameter prior to any calculation as it indicates entire container height
        textView.font = textViewFont
        textView.textContainerInset = UIEdgeInsets(top: textViewInsets, left: textViewInsets, bottom: textViewInsets, right: textViewInsets)

        let minHeight = textView.minimumHeight + textViewMargin*2
        textViewBar.frame = CGRect(x: 0, y: TextViewController.initialKbOrigin, width: view.width, height: minHeight)
        textViewBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textViewBar)
        textViewBar.fitHorzontallyToParent()
        textViewBarMaxHeight = textViewBar.setMaxHeight(textViewBarHidden ? 0 : maxTextViewBarHeight)

        leftButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(leftButtonsContainer)
        leftButtonsContainer.alignParentLeft(margin: viewMargins)
        leftButtonsContainer.alignParentBottom(margin: textViewMargin)
        leftButtonsContainer.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(textView)
        textView.fitVerticallyToParent(margin: textViewMargin)
        textView.toRightOf(leftButtonsContainer, margin: viewMargins)
        textViewRightConstraint = textView.alignParentRight(margin: viewMargins)
        textViewHeight = textView.setHeightConstraint(textView.minimumHeight)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(sendButton)
        sendButton.alignParentBottom()
        sendButton.toRightOf(textView, margin: viewMargins)
        sendButton.setHeightConstraint(minHeight)

        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(topSeparator)
        topSeparator.fitHorzontallyToParent()
        topSeparator.alignParentTop()
        topSeparator.backgroundColor = UIColor.lineGray
        topSeparator.setHeightConstraint(LGUIKitConstants.onePixelSize)

        textViewBar.toTopOf(keyboardView)

        mainResponder = textView
        textView.delegate = self
        textView.layer.borderWidth = LGUIKitConstants.onePixelSize
        textView.layer.borderColor = UIColor.lineGray.CGColor
        textView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        sendButton.setTitleColor(UIColor.redColor(), forState: .Normal)
        sendButton.setTitle("Send", forState: .Normal)

        setupTextAreaRx()
    }

    private func setupTextAreaRx() {
        let emptyText = textView.rx_text.map { $0.trim.isEmpty }
        emptyText.bindTo(sendButton.rx_hidden).addDisposableTo(disposeBag)
        emptyText.bindNext { [weak self] empty in
            guard let buttonWidth = self?.sendButton.width, let margin = self?.viewMargins else { return }
            self?.textViewRightConstraint.constant = empty ? margin : margin + buttonWidth + margin
            UIView.animateWithDuration(0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)

        textView.rx_text.bindNext { [weak self] _ in
            self?.fitTextView()
        }.addDisposableTo(disposeBag)

        sendButton.rx_tap.bindNext { [weak self] in self?.sendButtonPressed() }.addDisposableTo(disposeBag)
    }

    private func updateLeftActions() {
        leftActionsDisposeBag = DisposeBag()
        leftButtonsContainer.subviews.forEach { $0.removeFromSuperview() }

        let buttonDiameter = textView.minimumHeight
        var prevButton: UIButton?
        for action in leftActions {
            guard let image = action.image else { continue }
            let button = UIButton()
            button.setImage(image, forState: .Normal)
            button.rx_tap.subscribeNext(action.action).addDisposableTo(leftActionsDisposeBag)
            button.translatesAutoresizingMaskIntoConstraints = false
            leftButtonsContainer.addSubview(button)
            button.setHeightConstraint(buttonDiameter)
            button.setWidthConstraint(buttonDiameter)
            button.fitVerticallyToParent()
            if let prevButton = prevButton {
                button.toRightOf(prevButton)
            } else {
                button.alignParentLeft()
            }
            prevButton = button
        }
        if let lastButton = prevButton {
            lastButton.alignParentRight()
        }
    }

    private func fitTextView() {
        textViewHeight.constant = textView.appropriateHeight(textMaxLines)
    }
}



extension UITextView {

    var lineHeight: CGFloat {
        if font == nil {
            text = " " // Force font assignment
            text = ""
        }
        return font?.lineHeight ?? 0
    }

    var minimumHeight: CGFloat {
        var height = lineHeight;
        height += textContainerInset.top + textContainerInset.bottom;
        return height
    }

    func appropriateHeight(maxLines: UInt) -> CGFloat {
        var height: CGFloat = 0
        let minimumHeight = self.minimumHeight
        let numberOfLines = self.numberOfLines

        if numberOfLines == 1 {
            height = minimumHeight
        } else {
            height = heightForLines(min(numberOfLines, maxLines))
        }

        if (height < minimumHeight) {
            height = minimumHeight;
        }

        return CGFloat(roundf(Float(height)));
    }

    var numberOfLines: UInt {
        var contentHeight = contentSize.height;
        contentHeight -= textContainerInset.top + textContainerInset.bottom;
        guard let lineHeight = font?.lineHeight else { return 0 }
        let lines = fabs(contentHeight/lineHeight);

        // This helps preventing the content's height to be larger that the bounds' height
        // Avoiding this way to have unnecessary scrolling in the text view when there is only 1 line of content
        if lines == 1 && contentSize.height > bounds.size.height {
            contentSize.height = bounds.size.height
        }
        guard lines > 0 else { return 1 }
        return UInt(lines)
    }

    private func heightForLines(lines: UInt) -> CGFloat {
        var height = self.textContainerInset.top + self.textContainerInset.bottom
        height += CGFloat(roundf(Float(lineHeight)*Float(lines)));
        return height
    }
}
