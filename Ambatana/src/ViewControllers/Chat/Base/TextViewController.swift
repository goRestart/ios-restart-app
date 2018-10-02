import UIKit
import KMPlaceholderTextView
import RxSwift
import LGComponents

class TextViewController: KeyboardViewController {

    private enum Layout {
        static let textViewLeading: CGFloat = 16
        static let stickersButtonTrailing: CGFloat = -14
        static let letsMeetButtonSize = CGSize(width: 24, height: 24)
        static let letsMeetTrailingSpacing: CGFloat = 50
        static let textInputRightMargin: CGFloat = 28
    }
    
    var viewMargins: CGFloat = 10
    var textViewMargin: CGFloat = 6
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
    private let featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance
 
    let sendButton = UIButton(type: .custom)
    private let letsMeetButton: UIButton = {
        let button = UIButton()
        button.setImage(R.Asset.Chat.icCalendar.image, for: .normal)
        return button
    }()
    
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
    
    func letsMeetButtonPressed() {}

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
        textView.textInputView.backgroundColor = .clear
        // Set textview font parameter prior to any calculation as it indicates entire container height
        textView.font = textViewFont
        textView.textContainerInset = UIEdgeInsets(top: textViewInsets, left: textViewInsets, bottom: textViewInsets, right: Layout.textInputRightMargin)

        let minHeight = textView.minimumHeight + textViewMargin*2
        textViewBar.frame = CGRect(x: 0, y: TextViewController.initialKbOrigin, width: view.width, height: minHeight)
        textViewBar.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.clipsToBounds = true
        view.addSubview(textViewBar)
        textViewBar.layout(with: view).fillHorizontal()
 
        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewBar.addSubview(textView)
        textView.layout(with: textViewBar).top(by: textViewMargin)
            .right(by: -viewMargins, constraintBlock: {[weak self] in self?.textViewRightConstraint = $0 })
        textView.layout(with: textViewBar).leading(by: Layout.textViewLeading)
        textView.layout().height(textView.minimumHeight, constraintBlock: {[weak self] in self?.textViewHeight = $0 })
 
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        letsMeetButton.translatesAutoresizingMaskIntoConstraints = false
        
        textViewBar.addSubview(sendButton)
        sendButton.layout(with: textView).left(to: .right, by: viewMargins).centerY()
        sendButton.layout().height(minHeight)

        if featureFlags.shouldMoveLetsMeetAction {
            textViewBar.addSubviewForAutoLayout(letsMeetButton)
            
            let letsMeetButtonConstraints = [
                letsMeetButton.widthAnchor.constraint(equalToConstant: Layout.letsMeetButtonSize.width),
                letsMeetButton.heightAnchor.constraint(equalToConstant: Layout.letsMeetButtonSize.height),
                letsMeetButton.trailingAnchor.constraint(equalTo: textViewBar.trailingAnchor, constant: -Layout.textViewLeading),
                letsMeetButton.centerYAnchor.constraint(equalTo: textViewBar.centerYAnchor)
            ]
            letsMeetButtonConstraints.activate()
        }
   
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
        textView.cornerRadius = LGUIKitConstants.mediumCornerRadius
      
        sendButton.setTitleColor(UIColor.red, for: .normal)
    
        setupTextAreaRx()
        updateTextInputMargins()
        
        if let keyTextCache = keyForTextCaching() {
            textView.text = TextViewController.keyTextCache[keyTextCache]
        }
    }

    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        bottomSafeAreaHeight?.constant = view.safeAreaInsets.bottom
    }

    private func updateTextInputMargins() {
        if featureFlags.shouldMoveLetsMeetAction {
            textRightMargin = Layout.letsMeetTrailingSpacing
        }

        UIView.animate(withDuration: TextViewController.animationTime, delay: 0, options: [.beginFromCurrentState],
                       animations: { [weak self] in self?.view.layoutIfNeeded() }
            , completion: nil)
    }
    
    private func setupTextAreaRx() {
 
        textView.rx.text.bind { [weak self] text in
            self?.fitTextView()
        }.disposed(by: disposeBag)
 
        sendButton.rx.tap.bind { [weak self] in self?.sendButtonPressed() }.disposed(by: disposeBag)
        letsMeetButton.rx.tap.bind { [weak self] in self?.letsMeetButtonPressed() }.disposed(by: disposeBag)
        
        let emptyText = textView.rx.text.map { ($0 ?? "").trim.isEmpty }
        emptyText.bind(to: sendButton.rx.isHidden).disposed(by: disposeBag)
        
        textView.rx.text.skip(1).bind { [weak self] text in
            guard let keyTextCache = self?.keyForTextCaching() else { return }
            TextViewController.keyTextCache[keyTextCache] = text
        }.disposed(by: disposeBag)
        
        emptyText.bind { [weak self] empty in
            self?.configureInputViewMargins(isEmpty: empty)
        }.disposed(by: disposeBag)
    }
    
    private func configureInputViewMargins(isEmpty: Bool) {
        let letsMeetButtonMargin = featureFlags.shouldMoveLetsMeetAction ? Layout.letsMeetTrailingSpacing : viewMargins
        let rightConstraint = isEmpty ? letsMeetButtonMargin : (viewMargins * 2) + sendButton.width
        
        guard textRightMargin != rightConstraint else { return }
        textRightMargin = rightConstraint
        letsMeetButton.isHidden = !isEmpty || !featureFlags.shouldMoveLetsMeetAction
        
        UIView.animate(withDuration: TextViewController.animationTime, delay: 0, options: [.beginFromCurrentState], animations: { [weak self] in self?.view.layoutIfNeeded()
        }, completion: nil)
    }

    fileprivate func updateLeftActions() {
        leftActionsDisposeBag = DisposeBag()
        
        textView.subviews.forEach { if ($0 is UIButton) { $0.removeFromSuperview() } }
 
        for action in leftActions {
            guard let image = action.image else { continue }
            let button = UIButton()
            button.setImage(image, for: .normal)
            if let tint = action.imageTint {
                button.tintColor = tint
            }
            button.rx.tap.subscribeNext(onNext: action.action).disposed(by: leftActionsDisposeBag)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            textView.addSubview(button)
            button.widthAnchor.constraint(equalToConstant: Layout.letsMeetButtonSize.width).isActive = true
            button.heightAnchor.constraint(equalToConstant: Layout.letsMeetButtonSize.height).isActive = true
            button.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: Layout.stickersButtonTrailing).isActive = true
            button.centerYAnchor.constraint(equalTo: textViewBar.centerYAnchor).isActive = true
        }
        textViewBar.layoutIfNeeded()
    }

    fileprivate func fitTextView() {
        let appropriateHeight = textView.appropriateHeight(textMaxLines)
        textView.backgroundColor = .chatBoxBackground
        
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
