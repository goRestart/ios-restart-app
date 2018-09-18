struct LGEmptyViewModel {
    let icon: UIImage?
    let title: String?
    let body: String?
    let buttonTitle: String?
    let action: (() -> ())?
    let secondaryButtonTitle: String?
    let secondaryAction: (() -> ())?
    let emptyReason: EventParameterEmptyReason?
    let errorCode: Int?
    let errorDescription: String?
}

extension LGEmptyViewModel {
    struct Lenses {
        static let icon = Lens<LGEmptyViewModel, UIImage?>(
            get: {$0.icon},
            set: {(value, me) in LGEmptyViewModel(icon: value,
                                                  title: me.title,
                                                  body: me.body,
                                                  buttonTitle: me.buttonTitle,
                                                  action: me.action,
                                                  secondaryButtonTitle: me.secondaryButtonTitle,
                                                  secondaryAction: me.secondaryAction,
                                                  emptyReason: me.emptyReason,
                                                  errorCode: me.errorCode,
                                                  errorDescription: me.errorDescription) }
        )
    }
}

extension LGEmptyViewModel: Equatable {
    static func == (lhs: LGEmptyViewModel, rhs: LGEmptyViewModel) -> Bool {
        return lhs.title == rhs.title &&
            lhs.body == rhs.body &&
            lhs.buttonTitle == rhs.buttonTitle &&
            lhs.secondaryButtonTitle == rhs.secondaryButtonTitle &&
            lhs.emptyReason == rhs.emptyReason &&
            lhs.errorCode == rhs.errorCode &&
            lhs.errorDescription == rhs.errorDescription
    }
}
