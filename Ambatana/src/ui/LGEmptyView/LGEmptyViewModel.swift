struct LGEmptyViewModel {
    var icon: UIImage?
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
