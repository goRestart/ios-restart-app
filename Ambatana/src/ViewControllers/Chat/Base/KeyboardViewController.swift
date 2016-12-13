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

    private static func empty() -> KeyboardChange {
        return KeyboardChange(height: 0, origin: 0, animationTime: 0, animationOptions: [], visible: false, isLocal: false)
    }

    var description: String {
        return "height: \(height), origin: \(origin), time: \(animationTime), animOptions: \(animationOptions), visible:\(visible), isLocal: \(isLocal)"
    }
}

class KeyboardViewController: BaseViewController {

    static let initialKbOrigin = UIScreen.mainScreen().bounds.height
    static let initialKbWidth = UIScreen.mainScreen().bounds.width

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


    override init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .Default,
                              navBarBackgroundStyle: NavBarBackgroundStyle = .Default){
        super.init(viewModel: viewModel, nibName: nibNameOrNil, statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setup keyboard frame
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.userInteractionEnabled = false
        keyboardView.frame = CGRect(x: 0, y: KeyboardViewController.initialKbOrigin,
                                    width: KeyboardViewController.initialKbWidth, height: 0)
        view.addSubview(keyboardView)
        let views = [ "keyboardFrame" : keyboardView ]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[keyboardFrame]|", options: [],
            metrics: nil, views: views))
        keyboardHeightConstraint = NSLayoutConstraint(item: keyboardView, attribute: .Height, relatedBy: .Equal,
                                                      toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        keyboardTopConstraint = NSLayoutConstraint(item: keyboardView, attribute: .Top, relatedBy: .Equal, toItem: view,
                                                   attribute: .Top, multiplier: 1, constant: KeyboardViewController.initialKbOrigin)
        view.addConstraints([keyboardHeightConstraint, keyboardTopConstraint])
    }

    override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)
        if changes.value.visible {
            mainResponder?.becomeFirstResponder()
        }
        setObservers()
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        tearDownObservers()
    }


    // MARK: - Private

    private func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange),
                                                         name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidChange),
                                                         name:UIKeyboardDidChangeFrameNotification, object: nil)
    }

    private func tearDownObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidChangeFrameNotification, object: nil)
    }

    dynamic private func keyboardWillChange(notification: NSNotification) {
        applyChange(notification.keyboardChange, animated: true)
    }

    dynamic private func keyboardDidChange(notification: NSNotification) {
        applyChange(notification.keyboardChange, animated: false)
    }

    private func applyChange(kbChange: KeyboardChange, animated: Bool) {
        guard kbChange.isLocal else { return }
        // Main responder check
        if let mainResponder = mainResponder where kbChange.visible && !mainResponder.isFirstResponder() { return }
        guard changes.value.height != kbChange.height || changes.value.origin != kbChange.origin else { return }

        keyboardHeightConstraint.constant = kbChange.height
        keyboardTopConstraint.constant = kbChange.origin
        changes.value = kbChange

        if animated {
            UIView.animateWithDuration(Double(kbChange.animationTime), delay: 0, options: kbChange.animationOptions,
                                       animations: { [weak self] in self?.view.layoutIfNeeded() }, completion: nil)
        }
    }
}


private extension NSNotification {

    var keyboardChange: KeyboardChange {
        let height = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().height ?? 0
        let origin = (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().origin.y ?? KeyboardViewController.initialKbOrigin
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
            animOptions = UIViewAnimationOptions(rawValue: animCurve << 16) ?? []
        } else {
            animOptions = []
        }
        let visible = origin < KeyboardViewController.initialKbOrigin
        return KeyboardChange(height: height, origin: origin, animationTime: animationTime, animationOptions: animOptions,
                              visible: visible, isLocal: isLocal)
    }
}
