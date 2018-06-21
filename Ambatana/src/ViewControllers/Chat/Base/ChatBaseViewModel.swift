import RxSwift
import LGComponents

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
    
    let bag = DisposeBag()
}
