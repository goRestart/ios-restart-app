//
//  TextViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 30/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class TextViewController: KeyboardViewController {

    var viewMargins: CGFloat = 8
    var maxTextViewHeight: CGFloat = 100
    var minTextContainerHeight: CGFloat = 40
    var invertedTable = true {
        didSet {
            updateInverted()
        }
    }

    let tableView = UITableView()
    let aboveTextContainer = UIView()
    let textView = UITextView()
    let sendButton = UIButton(type: .Custom)
    var leftActions: [UIAction] = [] {
        didSet {
            updateLeftActions()
        }
    }

    private let leadingTextContainer = UIView()
    private var textViewRightConstraint = NSLayoutConstraint()
    private var textViewHeight: NSLayoutConstraint?
    private let textAreaContainer = UIView()
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
        tableView.toTopOf(textAreaContainer)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        updateInverted()

        tableView.keyboardDismissMode = .OnDrag
        tableView.delegate = self
        tableView.dataSource = self
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
}


// MARK: - TextArea

extension TextViewController {
    private func setupTextArea() {
        textAreaContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textAreaContainer)
        textAreaContainer.fitHorzontallyToParent()

        leadingTextContainer.translatesAutoresizingMaskIntoConstraints = false
        textAreaContainer.addSubview(leadingTextContainer)
        leadingTextContainer.alignParentLeft()
        leadingTextContainer.alignParentBottom()
        leadingTextContainer.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        textAreaContainer.addSubview(sendButton)
        sendButton.alignParentRight(margin: viewMargins)
        sendButton.alignParentBottom()

        textView.translatesAutoresizingMaskIntoConstraints = false
        textAreaContainer.addSubview(textView)
        textView.fitVerticallyToParent(margin: viewMargins)
        textView.toRightOf(leadingTextContainer, margin: viewMargins)
        textViewRightConstraint = textView.alignParentRight(margin: viewMargins)

        let topSeparator = UIView()
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        textAreaContainer.addSubview(topSeparator)
        topSeparator.fitHorzontallyToParent()
        topSeparator.alignParentTop()
        topSeparator.backgroundColor = UIColor.lineGray
        topSeparator.setHeightConstraint(LGUIKitConstants.onePixelSize)

        textAreaContainer.setMinHeight(minTextContainerHeight)
        textAreaContainer.toTopOf(keyboardView)



        mainResponder = textView
        textView.layer.borderWidth = LGUIKitConstants.onePixelSize
        textView.layer.borderColor = UIColor.lineGray.CGColor
        textView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius


        // TODO CORRECT TEXTS
        sendButton.setTitleColor(UIColor.redText, forState: .Normal)
        sendButton.setTitle("_Send", forState: .Normal)

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

        textView.rx_text.asObservable().bindNext { [weak self] _ in
            self?.fitTextViewHeight()
        }.addDisposableTo(disposeBag)
    }

    private func updateLeftActions() {
        leftActionsDisposeBag = DisposeBag()
        leadingTextContainer.subviews.forEach { $0.removeFromSuperview() }

        var prevButton: UIButton?
        for action in leftActions {
            guard let image = action.image else { continue }
            let button = UIButton()
            button.setImage(image, forState: .Normal)
            button.rx_tap.subscribeNext(action.action).addDisposableTo(leftActionsDisposeBag)
            button.translatesAutoresizingMaskIntoConstraints = false
            leadingTextContainer.addSubview(button)
            button.setHeightConstraint(minTextContainerHeight)
            button.setWidthConstraint(minTextContainerHeight)
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

    private func fitTextViewHeight() {
        let newHeight = min(maxTextViewHeight, textView.contentHeight)
        if let textViewHeight = textViewHeight {
            textViewHeight.constant = newHeight
        } else {
            textViewHeight = textView.setHeightConstraint(newHeight)
        }
    }
}

private extension UITextView {

    var contentHeight: CGFloat {

        var intrinsicContentSize = contentSize;
        intrinsicContentSize.width += (textContainerInset.left + textContainerInset.right ) / 2.0;
        intrinsicContentSize.height += (textContainerInset.top + textContainerInset.bottom) / 2.0;

        return intrinsicContentSize.height;
    }

}
