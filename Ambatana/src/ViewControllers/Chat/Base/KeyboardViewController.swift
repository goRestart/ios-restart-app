//
//  KeyboardViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 29/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

struct KeyboardChange: CustomStringConvertible {
    let height: CGFloat
    let origin: CGFloat
    let animationTime: CGFloat
    let animationOptions: UIViewAnimationOptions
    let visible: Bool
    /* Identifies whether the keyboard belongs to the current app. With multitasking on iPad, all visible apps are
     notified when the keyboard appears and disappears. The value of this key is true for the app that caused the 
     keyboard to appear and false for any other apps. */
    let isLocal: Bool

    fileprivate static func empty() -> KeyboardChange {
        return KeyboardChange(height: 0, origin: 0, animationTime: 0, animationOptions: [], visible: false, isLocal: false)
    }

    var description: String {
        return "height: \(height), origin: \(origin), time: \(animationTime), animOptions: \(animationOptions), visible:\(visible), isLocal: \(isLocal)"
    }
}

class KeyboardViewController: BaseViewController {

    static let initialKbOrigin = UIScreen.main.bounds.height
    static let initialKbWidth = UIScreen.main.bounds.width

    var keyboardChanges: Observable<KeyboardChange> {
        return changes.asObservable().skip(1)
    }
    var keyboardVisible: Bool {
        return changes.value.visible
    }
    var keyboardFrame: CGRect {
        return keyboardView.frame
    }

    let keyboardView = UIView()
    /*If provided, controller will check this responder to see if actually has focus when keyboard appears*/
    weak var mainResponder: UIResponder?

    private let changes = Variable<KeyboardChange>(KeyboardChange.empty())
    private var keyboardHeightConstraint = NSLayoutConstraint()
    private var keyboardTopConstraint = NSLayoutConstraint()


    override init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .default,
                              navBarBackgroundStyle: NavBarBackgroundStyle = .default, swipeBackGestureEnabled: Bool = true){
        super.init(viewModel: viewModel, nibName: nibNameOrNil, statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle, swipeBackGestureEnabled: swipeBackGestureEnabled)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup keyboard frame
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.isUserInteractionEnabled = false
        keyboardView.frame = CGRect(x: 0, y: KeyboardViewController.initialKbOrigin,
                                    width: KeyboardViewController.initialKbWidth, height: 0)
        view.addSubview(keyboardView)
        let views = [ "keyboardFrame" : keyboardView ]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[keyboardFrame]|", options: [],
            metrics: nil, views: views))
        keyboardHeightConstraint = NSLayoutConstraint(item: keyboardView, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        keyboardTopConstraint = NSLayoutConstraint(item: keyboardView, attribute: .top, relatedBy: .equal, toItem: view,
                                                   attribute: .top, multiplier: 1, constant: KeyboardViewController.initialKbOrigin)
        view.addConstraints([keyboardHeightConstraint, keyboardTopConstraint])
    }

    override func viewWillAppearFromBackground(_ fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        if changes.value.visible {
            mainResponder?.becomeFirstResponder()
        }
        setObservers()
    }

    override func viewWillDisappearToBackground(_ toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        tearDownObservers()
    }


    // MARK: - Private

    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChange),
                                                         name:NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }

    private func tearDownObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }

    dynamic private func keyboardWillChange(_ notification: Notification) {
        applyChange(notification.keyboardChange, animated: true)
    }

    dynamic private func keyboardDidChange(_ notification: Notification) {
        applyChange(notification.keyboardChange, animated: false)
    }

    private func applyChange(_ kbChange: KeyboardChange, animated: Bool) {
        guard kbChange.isLocal else { return }
        // Main responder check
        if let mainResponder = mainResponder, kbChange.visible && !mainResponder.isFirstResponder { return }
        guard changes.value.height != kbChange.height || changes.value.origin != kbChange.origin else { return }

        keyboardHeightConstraint.constant = kbChange.height
        keyboardTopConstraint.constant = kbChange.origin
        changes.value = kbChange

        if animated {
            UIView.animate(withDuration: Double(kbChange.animationTime), delay: 0, options: kbChange.animationOptions,
                                       animations: { [weak self] in self?.view.layoutIfNeeded() }, completion: nil)
        }
    }
}


extension Notification {
    var keyboardChange: KeyboardChange {
        let height = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        let origin = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.origin.y ?? KeyboardViewController.initialKbOrigin
        let animationTime = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? CGFloat) ?? 0.25
        let isLocal: Bool
        if #available(iOS 9.0, *) {
            isLocal = (userInfo?[UIKeyboardIsLocalUserInfoKey] as? Bool) ?? true
        } else {
            isLocal = true
        }
        let animOptions: UIViewAnimationOptions
        if let animCurve = userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
            // From: http://stackoverflow.com/a/26939315/1666070
            animOptions = UIViewAnimationOptions(rawValue: animCurve << 16)
        } else {
            animOptions = []
        }
        let visible = origin < KeyboardViewController.initialKbOrigin
        return KeyboardChange(height: height, origin: origin, animationTime: animationTime, animationOptions: animOptions,
                              visible: visible, isLocal: isLocal)
    }
}
