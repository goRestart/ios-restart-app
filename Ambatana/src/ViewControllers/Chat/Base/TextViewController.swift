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
    var tableBottomMargin: CGFloat = 0 {
        didSet {
            tableBottomMarginConstraint.constant = -tableBottomMargin
        }
    }

    var textMaxLines: UInt = 6
    var invertedTable = true {
        didSet {
            updateInverted()
        }
    }
    var textViewBarHidden = false {
        didSet {
            textViewBarBottom.constant = textViewBarHidden ? textViewBar.height : 0
        }
    }
    var textViewFont: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            textView.font = textViewFont
            fitTextView()
        }
    }

    let tableView = UITableView()
    var singleTapGesture: UITapGestureRecognizer?
    let textViewBar = UIView()
    let textView = KMPlaceholderTextView()
    let bottomSafeArea = UIView()
    var bottomSafeAreaHeight: NSLayoutConstraint?

    let leftButtonsContainer = UIView()
    let sendButton = UIButton(type: .custom)
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

    fileprivate static let animationTime: TimeInterval = 0.2
    fileprivate static var keyTextCache = [String : String]()

    fileprivate let maxTextViewBarHeight: CGFloat = 1000
    fileprivate let textViewInsets: CGFloat = 7
    fileprivate var textViewBarBottom = NSLayoutConstraint()
    fileprivate var textViewRightConstraint = NSLayoutConstraint()
    var textRightMargin: CGFloat {
        get {
            return -textViewRightConstraint.constant
        }
        set {
            textViewRightConstraint.constant = -newValue
        }
    }
    fileprivate var textViewHeight = NSLayoutConstraint()
    fileprivate var tableBottomMarginConstraint = NSLayoutConstraint()
    fileprivate var leftActionsDisposeBag = DisposeBag()
    fileprivate let disposeBag = DisposeBag()


    override init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .default,
                  navBarBackgroundStyle: NavBarBackgroundStyle = .default, swipeBackGestureEnabled: Bool = true){
        super.init(viewModel: viewModel, nibName: nibNameOrNil, statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle, swipeBackGestureEnabled: swipeBackGestureEnabled)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Public

    func setTextViewBarHidden(_ hidden: Bool, animated: Bool) {
        guard textViewBarHidden != hidden else { return }
        textViewBarHidden = hidden
        if animated {
            UIView.animate(withDuration: TextViewController.animationTime,
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations: { [weak self] in self?.view.layoutIfNeeded()},
                           completion: { [weak self] _ in self?.textViewBar.isHidden = hidden }
            )
        } else {
            textViewBar.isHidden = hidden
        }
    }

    func presentKeyboard(_ animated: Bool) {
        guard !textViewBarHidden && !textView.isFirstResponder else { return }
        if !animated {
            UIView.performWithoutAnimation { [weak self] in
                self?.textView.becomeFirstResponder()
            }
        } else {
            textView.becomeFirstResponder()
        }
    }

    func dismissKeyboard(_ animated: Bool) {

        // Dismisses the keyboard from any first responder in the window.
        if !textView.isFirstResponder && keyboardVisible {
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

    func setTableBottomMargin(_ margin: CGFloat, animated: Bool) {
        let tableSuperView = tableView.superview
        tableBottomMargin = margin
        if animated {
            UIView.animate(withDuration: TextViewController.animationTime, delay: 0, options: [.beginFromCurrentState],
                                       animations: { tableSuperView?.layoutIfNeeded() }, completion: nil)
        }
    }


    // MARK: - Methods to override

    func sendButtonPressed() { }

    func scrollViewDidTap() { }

    func keyForTextCaching() -> String? { return nil }


    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = UIColor.white
        setupTextArea()
        setupTable()
        view.bringSubview(toFront: textViewBar)

        updateLeftActions()

        let margin = textViewMargin

        keyboardChanges.asObservable().bind { [weak self] change in
            if change.visible {
                self?.bottomSafeAreaHeight?.constant = margin
            } else {
                var safeArea: CGFloat = margin
                if #available(iOS 11, *), let safeAreaBottom = self?.view.safeAreaInsets.bottom {
                    safeArea = max(safeAreaBottom, margin)
                }
                self?.bottomSafeAreaHeight?.constant = safeArea
            }
        }.disposed(by: disposeBag)
    }
}


// MARK: - Table

extension TextViewController {

    fileprivate func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.layout(with: view).fillHorizontal().top()
        tableView.layout(with: textViewBar)
            .bottom(to: .top, by: -tableBottomMargin, constraintBlock: { [weak self] in self?.tableBottomMarginConstraint = $0 })
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.clipsToBounds = false
        updateInverted()

        tableView.keyboardDismissMode = .onDrag

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTap))
        tapGesture.require(toFail: tableView.panGestureRecognizer)
        tableView.addGestureRecognizer(tapGesture)
        singleTapGesture = tapGesture
    }

    fileprivate func updateInverted() {
        tableView.transform = invertedTable ? CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0) : CGAffineTransform.identity
    }

    @objc fileprivate func scrollViewTap() {
        dismissKeyboard(true)
        scrollViewDidTap()
    }
}


// MARK: - TextArea

extension TextViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }

    fileprivate func setupTextArea() {
        // Set textview font parameter prior to any calculation as it indicates entire container height
        textView.font = textViewFont
        textView.textContainerInset = UIEdgeInsets(top: textViewInsets, left: textViewInsets, bottom: textViewInsets, right: textViewInsets)

        let minHeight = textView.minimumHeight + textViewMargin*2
        textViewBar.frame = CGRect(x: 0, y: TextViewController.initialKbOrigin, width: view.width, height: minHeight)
        textViewBar.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.clipsToBounds = true
        view.addSubview(textViewBar)
        textViewBar.layout(with: view).fillHorizontal()

        leftButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(leftButtonsContainer)
        leftButtonsContainer.layout(with: textViewBar).left(by: viewMargins)
        leftButtonsContainer.setContentHuggingPriority(.required, for: .horizontal)

        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(textView)
        textView.layout(with: textViewBar).top(by: textViewMargin)
            .right(by: -viewMargins, constraintBlock: {[weak self] in self?.textViewRightConstraint = $0 })
        textView.layout(with: leftButtonsContainer).left(to: .right, by: viewMargins)
        textView.layout().height(textView.minimumHeight, constraintBlock: {[weak self] in self?.textViewHeight = $0 })

        leftButtonsContainer.layout(with: textView).centerY()

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(sendButton)
        sendButton.layout(with: textView).left(to: .right, by: viewMargins).centerY()
        sendButton.layout().height(minHeight)

        bottomSafeArea.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(bottomSafeArea)
        bottomSafeArea.layout(with: textView).below()
        bottomSafeArea.layout(with: textViewBar).fillHorizontal().bottom()
        bottomSafeAreaHeight = bottomSafeArea.heightAnchor.constraint(equalToConstant: 0)
        bottomSafeAreaHeight?.isActive = true

        textViewBar.addTopViewBorderWith(width: LGUIKitConstants.onePixelSize, color: UIColor.lineGray)

        textViewBar.layout(with: keyboardView).bottom(to: .top, by: textViewBarHidden ? textViewBar.height : 0,
                                                      constraintBlock: {[weak self] in self?.textViewBarBottom = $0 })

        mainResponder = textView
        textView.delegate = self
        textView.layer.borderWidth = LGUIKitConstants.onePixelSize
        textView.layer.borderColor = UIColor.lineGray.cgColor
        textView.cornerRadius = LGUIKitConstants.smallCornerRadius

        sendButton.setTitleColor(UIColor.red, for: .normal)
        sendButton.setTitle("Send", for: .normal)

        setupTextAreaRx()

        if let keyTextCache = keyForTextCaching() {
            textView.text = TextViewController.keyTextCache[keyTextCache]
        }
    }

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        bottomSafeAreaHeight?.constant = view.safeAreaInsets.bottom
    }

    private func setupTextAreaRx() {
        let emptyText = textView.rx.text.map { ($0 ?? "").trim.isEmpty }
        emptyText.bind(to: sendButton.rx.isHidden).disposed(by: disposeBag)
        emptyText.bind { [weak self] empty in
                guard let strongSelf = self, let margin = self?.viewMargins else { return }
                let rightConstraint = empty ? margin : margin + strongSelf.sendButton.width + margin
                guard strongSelf.textRightMargin != rightConstraint else { return }
                self?.textRightMargin = rightConstraint
                UIView.animate(withDuration: TextViewController.animationTime, delay: 0, options: [.beginFromCurrentState],
                               animations: { [weak self] in self?.view.layoutIfNeeded() }, completion: nil)
                }.disposed(by: disposeBag)

        textView.rx.text.bind { [weak self] text in
            self?.fitTextView()
        }.disposed(by: disposeBag)

        textView.rx.text.skip(1).bind { [weak self] text in
            guard let keyTextCache = self?.keyForTextCaching() else { return }
            TextViewController.keyTextCache[keyTextCache] = text
        }.disposed(by: disposeBag)

        sendButton.rx.tap.bind { [weak self] in self?.sendButtonPressed() }.disposed(by: disposeBag)
    }

    fileprivate func updateLeftActions() {
        leftActionsDisposeBag = DisposeBag()
        leftButtonsContainer.subviews.forEach { $0.removeFromSuperview() }

        let buttonDiameter = textView.minimumHeight
        var prevButton: UIButton?
        for action in leftActions {
            guard let image = action.image else { continue }
            let button = UIButton()
            button.setImage(image, for: .normal)
            if let tint = action.imageTint {
                button.tintColor = tint
            }
            button.rx.tap.subscribeNext(onNext: action.action).disposed(by: leftActionsDisposeBag)
            button.translatesAutoresizingMaskIntoConstraints = false
            leftButtonsContainer.addSubview(button)
            button.layout().width(buttonDiameter).widthProportionalToHeight()
            button.layout(with: leftButtonsContainer).fillVertical()
            if let prevButton = prevButton {
                button.layout(with: prevButton).left(to: .right)
            } else {
                button.layout(with: leftButtonsContainer).left()
            }
            prevButton = button
        }
        if let lastButton = prevButton {
            lastButton.layout(with: leftButtonsContainer).right()
        }
        textViewBar.layoutIfNeeded()
    }

    fileprivate func fitTextView() {
        let appropriateHeight = textView.appropriateHeight(textMaxLines)
        guard textViewHeight.constant != appropriateHeight else { return }
        textViewHeight.constant = appropriateHeight
        if textView.isFirstResponder {
            
            UIView.animate(withDuration: TextViewController.animationTime, delay: 0,
                                       options: [.layoutSubviews, .beginFromCurrentState, .curveEaseInOut],
                                       animations: { [weak self] in
                                            self?.textView.scrollToCaret(animated: false)
                                        }, completion: nil)
        }
    }
}
