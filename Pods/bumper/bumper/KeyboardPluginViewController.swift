import UIKit

extension UIViewController {
    func attachKeyboardViewControllerTo<T>(_ viewController: T) where T: UIViewController, T: KeyboardDelegate {
        let keyboardViewController = KeyboardPluginViewController(withDelegate: viewController)
        keyboardViewController.view.isHidden = true
        keyboardViewController.delegate = viewController
        viewController.addChildViewController(keyboardViewController)
        viewController.view.addSubview(keyboardViewController.view)
    }
}

struct KeyboardData {

    var height : Float = 0.0
    var maxYCoordinate : Float = 0.0
    var animationDuration : Float = 0.0
    var animationCurve : UIViewAnimationCurve = .easeInOut

    mutating func update(withDictionary dictionary : Dictionary<AnyHashable, Any>) {
        if let duration = dictionary[UIKeyboardAnimationDurationUserInfoKey] as? Float {
            self.animationDuration = duration
        }
        if let curve = dictionary[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve {
            self.animationCurve = curve
        }
        if let size = (dictionary[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.height = Float(size.height)
            self.maxYCoordinate = Float(UIScreen.main.bounds.size.height - size.origin.y)
        }
    }
}

protocol KeyboardDelegate: NSObjectProtocol {
    func update(withKeyboard keyboard: KeyboardData)
}

final class KeyboardPluginViewController: UIViewController {

    weak var delegate: KeyboardDelegate?

    init(withDelegate delegate: KeyboardDelegate) {
        self.delegate? = delegate
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        self.view = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configKeyboard()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.removeFromSuperview()
        self.unsubscribeFromKeyboardEvents()
    }

    func configKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        var keyboard = KeyboardData()
        keyboard.update(withDictionary: userInfo)
        self.delegate?.update(withKeyboard: keyboard)
    }

    private func unsubscribeFromKeyboardEvents() {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
