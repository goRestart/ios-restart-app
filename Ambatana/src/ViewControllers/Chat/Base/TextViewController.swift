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

    let viewMargins: CGFloat = 8

    let tableView = UITableView()
    let aboveTextContainer = UIView()
    let leadingTextContainer = UIView()
    let textView = UITextView()
    var textViewRightConstraint = NSLayoutConstraint()
    let sendButton = UIButton(type: .Custom)

    private let textAreaContainer = UIView()

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
        setupTextUI()
        setupTable()
    }


    private func setupTextUI() {
        textAreaContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textAreaContainer)
        textAreaContainer.fitHorzontallyToParent()

        leadingTextContainer.translatesAutoresizingMaskIntoConstraints = false
        textAreaContainer.addSubview(leadingTextContainer)
        leadingTextContainer.fitVerticallyToParent()
        leadingTextContainer.alignParentLeft()
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

        textAreaContainer.setMinHeight(40)
        textAreaContainer.toTopOf(keyboardView)

        let emptyText = textView.rx_text.map { $0.trim.isEmpty }
        emptyText.bindTo(sendButton.rx_hidden).addDisposableTo(disposeBag)
        emptyText.bindNext { [weak self] empty in
            guard let buttonWidth = self?.sendButton.width, let margin = self?.viewMargins else { return }
            self?.textViewRightConstraint.constant = empty ? margin : margin + buttonWidth + margin
            UIView.animateWithDuration(0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }.addDisposableTo(disposeBag)

        mainResponder = textView
        textView.layer.borderWidth = LGUIKitConstants.onePixelSize
        textView.layer.borderColor = UIColor.lineGray.CGColor
        textView.scrollEnabled = false

        // TODO CORRECT TEXTS
        sendButton.setTitleColor(UIColor.redText, forState: .Normal)
        sendButton.setTitle("_Send", forState: .Normal)
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.fitHorzontallyToParent()
        tableView.alignParentTop()
        tableView.toTopOf(textAreaContainer)

        tableView.keyboardDismissMode = .OnDrag
    }
}
