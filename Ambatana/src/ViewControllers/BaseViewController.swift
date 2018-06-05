import LGCoreKit
import LGComponents

// MARK: - ToastView

private struct TostableKeys {
    static var ToastViewKey = 0
    static var ToastViewBottomMarginConstraintKey = 0
}

private struct NavigationBarKeys {
    static var letTouchesPass = 0
    static var viewsToIgnoreTouchersFor = 0
    static var outOfBoundsViewsToForceTouches = 0
}


extension UINavigationBar {

    var outOfBoundsViewsToForceTouches: [UIView] {
        get {
            let views = objc_getAssociatedObject(self, &NavigationBarKeys.outOfBoundsViewsToForceTouches) as? [UIView]
            return views ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &NavigationBarKeys.outOfBoundsViewsToForceTouches,
                newValue as [UIView]?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }


    var viewsToIgnoreTouchesFor: [UIView] {
        get {
            let views = objc_getAssociatedObject(self, &NavigationBarKeys.viewsToIgnoreTouchersFor) as? [UIView]
            return views ?? []
        }
        set {
            objc_setAssociatedObject(
                self,
                &NavigationBarKeys.viewsToIgnoreTouchersFor,
                newValue as [UIView]?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func forceTouchesFor(_ view: UIView) {
        var views = outOfBoundsViewsToForceTouches
        views.append(view)
        outOfBoundsViewsToForceTouches = views
    }
    
    func endForceTouchesFor(_ view: UIView) {
        var views = outOfBoundsViewsToForceTouches
        if let indexToRemove = views.index(of: view) {
            views.remove(at: indexToRemove)
        }
        outOfBoundsViewsToForceTouches = views
    }

    func ignoreTouchesFor(_ view: UIView) {
        var views = viewsToIgnoreTouchesFor
        views.append(view)
        viewsToIgnoreTouchesFor = views
    }
    
    func endIgnoreTouchesFor(_ view: UIView) {
        var views = viewsToIgnoreTouchesFor
        if let indexToRemove = views.index(of: view) {
            views.remove(at: indexToRemove)
        }
        viewsToIgnoreTouchesFor = views
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let pointInside = super.point(inside: point, with: event)

        for view in viewsToIgnoreTouchesFor {
            let convertedPoint = view.convert(point, from: self)
            if view.point(inside: convertedPoint, with: event) {
                return false
            }
        }

        for view in outOfBoundsViewsToForceTouches {
            let convertedPoint = view.convert(point, from: self)
            if view.point(inside: convertedPoint, with: event) {
                return true
            }
        }

        return pointInside
    }
}

extension UIViewController {

    var toastView: ToastView? {
        get {
            var toast = objc_getAssociatedObject(self, &TostableKeys.ToastViewKey) as? ToastView
            if toast == nil {
                toast = ToastView()
                self.toastView = toast
            }
            return toast
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &TostableKeys.ToastViewKey,
                    newValue as ToastView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    private var toastViewBottomMarginConstraint: NSLayoutConstraint? {
        get {
            return objc_getAssociatedObject(self, &TostableKeys.ToastViewBottomMarginConstraintKey) as? NSLayoutConstraint
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &TostableKeys.ToastViewBottomMarginConstraintKey,
                    newValue as NSLayoutConstraint?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }

    var isSafeAreaAvailable: Bool {
        if #available(iOS 11.0, *) {
            return true
        }
        return false
    }

    var navigationBarHeight: CGFloat {
        guard let navController = navigationController else { return 0 }
        return navController.navigationBar.frame.size.height
    }

    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    var topBarHeight: CGFloat {
        return navigationBarHeight + statusBarHeight
    }
    
    var tabBarHeight: CGFloat {
        guard let tabController = tabBarController else { return 0 }
        
        return tabController.tabBar.frame.size.height
    }
    
    private var toastViewBottomMarginVisible: CGFloat {
        guard let toastView = toastView else { return 0 }
        let toastViewHeight = toastView.height > ToastView.standardHeight ? toastView.height : ToastView.standardHeight
        // In case there's no navigation bar, we should add a margin (tipically a standard navbar height) to avoid showing the toast above close button
        guard let _ = navigationController?.navigationBar else { return (44 + toastViewHeight) }
        return (toastViewHeight)
    }
    
    private var toastViewBottomMarginHidden: CGFloat {
        return 0
    }
    
    
    /**
    Shows/hides the toast view with the given message.
    
    - parameter hidden: If the toast view should be hidden.
    */
    func setToastViewHidden(_ hidden: Bool) {
        guard let toastView = toastView else { return }
        view.bringSubview(toFront: toastView)
        toastViewBottomMarginConstraint?.constant = hidden ? toastViewBottomMarginHidden : toastViewBottomMarginVisible
        UIView.animate(withDuration: 0.35, animations: {
            toastView.alpha = hidden ? 0 : 1
            toastView.layoutIfNeeded()
        }) 
    }
    
    func setupToastView() {
        guard let toastView = toastView else { return }
        toastView.translatesAutoresizingMaskIntoConstraints = false
        toastView.alpha = 0
        toastView.isUserInteractionEnabled = false
        view.addSubview(toastView)
        
        toastViewBottomMarginConstraint = NSLayoutConstraint(item: toastView, attribute: .bottom, relatedBy: .equal,
            toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: toastViewBottomMarginHidden)
        if let bottomConstraint = toastViewBottomMarginConstraint { view.addConstraint(bottomConstraint) }
        
        let views = ["toastView": toastView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[toastView]|", options: [], metrics: nil, views: views))
    }
}

// MARK: - NavigationBar

enum NavBarTransparentSubStyle {
    case dark, light
}

enum NavBarBackgroundStyle {
    case white
    case transparent(substyle: NavBarTransparentSubStyle)
    case custom(background: UIImage, shadow: UIImage)
    case `default`

    var tintColor: UIColor {
        switch self {
        case let .transparent(substyle):
            switch substyle {
            case .dark:
                return .clearBarButton
            case .light:
                return UIColor.lightBarButton
            }
        case .default, .custom, .white:
            return UIColor.lightBarButton
        }
    }

    var titleColor: UIColor {
        switch self {
        case let .transparent(substyle):
            switch substyle {
            case .dark:
                return .clearBarTitle
            case .light:
                return UIColor.lightBarTitle
            }
        case .default, .custom, .white:
            return UIColor.lightBarTitle
        }
    }
}

enum NavBarTitleStyle {
    case text(String?)
    case image(UIImage)
    case custom(UIView)
}

extension UIViewController {

    func setNavBarTitle(_ title: String?) {
        setNavBarTitleStyle(.text(title))
    }

    func setNavBarTitleStyle(_ style: NavBarTitleStyle) {
        switch style {
        case let .text(text):
            self.navigationItem.title = text
        case let .image(image):
            self.navigationItem.titleView = UIImageView(image: image)
        case let .custom(view):
            self.navigationItem.titleView = view
        }
    }

    func setNavBarBackButton(_ icon: UIImage? = nil, selector: Selector? = nil) {
        guard !isRootViewController() else { return }
        let backIconImage = icon ?? R.Asset.IconsButtons.navbarBack.image
        let backButton = UIBarButtonItem(image: backIconImage, style: .plain,
                                         target: self, action: selector ?? #selector(UIViewController.popBackViewController))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setNavBarBackgroundStyle(_ style: NavBarBackgroundStyle) {
        switch style {
        case .white:
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.barTintColor = .white
        case .transparent:
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
        case let .custom(background, shadow):
            navigationController?.navigationBar.setBackgroundImage(background, for: .default)
            navigationController?.navigationBar.shadowImage = shadow
        case .default:
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
        }

        navigationController?.navigationBar.tintColor = style.tintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont.pageTitleFont,
                                                                   NSAttributedStringKey.foregroundColor : style.titleColor]
    }
}


// MARK: - BaseViewController

class BaseViewController: UIViewController, TabBarShowable {

    // VM & active
    private var viewModel: BaseViewModel?
    private var subviews: [BaseView]
    private var firstAppear: Bool = true
    private var firstWillAppear: Bool = true
    private var firstLayout: Bool = true
    var active: Bool = false {
        didSet {
            // Notify the VM & the views
            viewModel?.active = active
            
            for subview in subviews {
                subview.active = active
            }
        }
    }
    var hasTabBar: Bool = false
    
    // UI
    private var statusBarStyle: UIStatusBarStyle
    private let previousStatusBarStyle: UIStatusBarStyle
    private let navBarBackgroundStyle: NavBarBackgroundStyle
    private var swipeBackGestureEnabled: Bool
    var floatingSellButtonHidden: Bool
    private(set) var didCallViewDidLoaded: Bool = false

    // MARK: Lifecycle

    init(viewModel: BaseViewModel?, nibName nibNameOrNil: String?, statusBarStyle: UIStatusBarStyle = .default,
         navBarBackgroundStyle: NavBarBackgroundStyle = .default, swipeBackGestureEnabled: Bool = true) {
        self.viewModel = viewModel
        self.subviews = []
        self.statusBarStyle = statusBarStyle
        self.previousStatusBarStyle = UIApplication.shared.statusBarStyle
        self.navBarBackgroundStyle = navBarBackgroundStyle
        self.floatingSellButtonHidden = false
        self.swipeBackGestureEnabled = swipeBackGestureEnabled
        super.init(nibName: nibNameOrNil, bundle: nil)

        // Setup
        hidesBottomBarWhenPushed = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func popBackViewController() {
        let viewModelDidHandleBack = viewModel?.backButtonPressed() ?? false
        if !viewModelDidHandleBack {
            super.popBackViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        didCallViewDidLoaded = true
        setNavBarBackButton()
        
        setupToastView()
        setReachabilityEnabled(true)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = swipeBackGestureEnabled
        view.backgroundColor = UIColor.viewControllerBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearFromBackground(false)
        if firstWillAppear {
            viewWillFirstAppear(animated)
            firstWillAppear = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewWillDisappearToBackground(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            viewDidFirstAppear(animated)
            firstAppear = false
        }
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        navigationController?.interactivePopGestureRecognizer?.isEnabled = swipeBackGestureEnabled
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstLayout {
            viewDidFirstLayoutSubviews()
            firstLayout = false
        }
    }
    
    func viewWillFirstAppear(_ animated: Bool) {
        // implement in subclasses
    }

    func viewDidFirstAppear(_ animated: Bool) {
        // implement in subclasses
    }

    func viewDidFirstLayoutSubviews() {
        // implement in subclasses
    }
    
    // MARK: Extended lifecycle
    
    internal func viewWillAppearFromBackground(_ fromBackground: Bool) {
        setNavBarBackgroundStyle(navBarBackgroundStyle)

        if !fromBackground {
            setNeedsStatusBarAppearanceUpdate()
            NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }
        active = true
    }
    
    internal func viewWillDisappearToBackground(_ toBackground: Bool) {
        
        if !toBackground {
            if !isRootViewController() || isModal {
                statusBarStyle = previousStatusBarStyle
                setNeedsStatusBarAppearanceUpdate()
            }
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        }
        active = false
    }
    
    // MARK: StatusBarStyle

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    // MARK: Subview handling
    
    func addSubview(_ subview: BaseView) {
        //Adding to managed subviews
        if !subviews.contains(subview) {
            subviews.append(subview)
            
            //Set current state to subview
            subview.active = self.active
        }
    }
    
    func removeSubview(_ subview: BaseView) {
        if subviews.contains(subview) {
            subviews = subviews.filter { return $0 !== subview }
            
            //Set inactive state to subview
            subview.active = false
        }
    }
    
    // MARK: NSNotificationCenter
    
    @objc private func applicationDidEnterBackground(_ notification: Notification) {
        viewWillDisappearToBackground(true)
    }
    
    @objc private func applicationWillEnterForeground(_ notification: Notification) {
        viewWillAppearFromBackground(true)
    }
    
    // MARK: Reachability
    
    private var reachability: ReachabilityProtocol?
    private var reachabilityEnabled: Bool?
    private var reachable: Bool? {
        return reachability?.isReachable
    }
    func setReachabilityEnabled(_ enabled: Bool) {
        if enabled {
            reachability = LGReachability()
            reachability?.reachableBlock = { [weak self] in
                self?.setToastViewHidden(true)
            }
            reachability?.unreachableBlock = { [weak self] in
                self?.setToastViewHidden(false)
                self?.toastView?.title = R.Strings.toastNoNetwork
            }
            reachability?.start()
        } else {
            reachability = nil
        }
    }
}
