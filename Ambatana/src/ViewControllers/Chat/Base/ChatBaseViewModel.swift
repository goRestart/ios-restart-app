import RxSwift
import LGComponents
import LGCoreKit

struct VMActionSheet {
    let cancelTitle: String
    let actions: [UIAction]
    
    init(cancelTitle: String = R.Strings.commonCancel,
         actions: [UIAction]) {
        self.cancelTitle = cancelTitle
        self.actions = actions
    }
}

enum VMActionStyle {
    case `default`, cancel, destructive
    
    var alertActionStyle: UIAlertActionStyle {
        switch self {
        case .default:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

struct VMAction {
    let title: String
    let style: VMActionStyle
    let handler: (() -> Void)?
    
    init(title: String,
         style: VMActionStyle = .default,
         handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

struct VMPresentAlert {
    let title: String?
    let message: String?
    let actions: [VMAction]
    let animated: Bool
    let completion: (() -> Void)?
    
    init(title: String?,
         message: String?,
         actions: [VMAction],
         animated: Bool = true,
         completion: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.actions = actions
        self.animated = animated
        self.completion = completion
    }
}

struct VMPresentAutofadingAlert {
    let title: String?
    let message: String
    let time: TimeInterval

    init(title: String?,
         message: String,
         time: TimeInterval = kLetGoFadingAlertDismissalTime) {
        self.title = title
        self.message = message
        self.time = time
    }
}

struct VMPresentLoadingMessage {
    let message: String
    
    init(message: String = R.Strings.commonLoading) {
        self.message = message
    }
}

struct VMDismissLoadingMessage {
    let endingMessage: String?
    let completion: (() -> Void)?
    
    init(endingMessage: String? = nil,
         completion: (() -> Void)? = nil) {
        self.endingMessage = endingMessage
        self.completion = completion
    }
}

class ChatBaseViewModel: BaseViewModel {
    let rx_vmPresentActionSheet = PublishSubject<VMActionSheet>()
    let rx_vmPresentAlert = PublishSubject<VMPresentAlert>()
    let rx_vmPresentLoadingMessage = PublishSubject<VMPresentLoadingMessage>()
    let rx_vmDismissLoadingMessage = PublishSubject<VMDismissLoadingMessage>()
    let rx_vmPresentAutofadingAlert = PublishSubject<VMPresentAutofadingAlert>()
    
    private let reachability: ReachabilityProtocol
    let rx_isReachable = Variable<Bool>(true)
    
    let bag = DisposeBag()
    
    // MARK: Lifecycle
    
    init(reachability: ReachabilityProtocol = LGReachability()) {
        self.reachability = reachability
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        if firstTime {
            setupReachability()
        }
    }
    
    // MARK: Reachability
    
    private func setupReachability() {
        reachability.reachableBlock = { [weak self] in
            self?.rx_isReachable.value = true
        }
        reachability.unreachableBlock = { [weak self] in
            self?.rx_isReachable.value = false
        }
        reachability.start()
    }
}
