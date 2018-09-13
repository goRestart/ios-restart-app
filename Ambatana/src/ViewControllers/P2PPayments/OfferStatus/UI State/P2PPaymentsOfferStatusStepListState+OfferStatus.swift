import Foundation
import LGCoreKit

// TODO: @juolgon Localize all texts

extension P2PPaymentsOfferStatusStepListState {
    typealias ButtonTapHandler = () -> Void

    static func buyerStepList(status: P2PPaymentOfferStatus,
                              listingPrice: Double,
                              currency: Currency,
                              withdrawnButtonTapHandler: ButtonTapHandler?) -> P2PPaymentsOfferStatusStepListState {
        let stepOne = P2PPaymentsOfferStatusStepViewState.buyerStepOne(status: status,
                                                                       listingPrice: listingPrice,
                                                                       currency: currency,
                                                                       withdrawnButtonTapHandler: withdrawnButtonTapHandler)
        let stepTwo = P2PPaymentsOfferStatusStepViewState.buyerStepTwo(status: status)
        let stepThree = P2PPaymentsOfferStatusStepViewState.buyerStepThree(status: status)
        let currentStep: CurrentStep = {
            switch status {
            case .canceled, .expired, .error: return .failed(0)
            case .pending: return .completed(0)
            case .declined: return .failed(1)
            case .accepted: return .completed(1)
            case .completed: return .completed(2)
            }
        }()
        return P2PPaymentsOfferStatusStepListState(steps: [stepOne, stepTwo, stepThree],
                                                   currentStep: currentStep)
    }

    static func sellerStepList(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepListState {
        let stepOne = P2PPaymentsOfferStatusStepViewState.sellerStepOne(status: status)
        let stepTwo = P2PPaymentsOfferStatusStepViewState.sellerStepTwo()
        let currentStep: CurrentStep = {
            switch status {
            case .pending: return .completed(-1)
            case .canceled, .expired, .error, .declined: return .failed(0)
            case .accepted: return .completed(0)
            case .completed: return .completed(1)
            }
        }()
        return P2PPaymentsOfferStatusStepListState(steps: [stepOne, stepTwo],
                                                   currentStep: currentStep)
    }
}

extension P2PPaymentsOfferStatusStepViewState {
    static let currencyHelper = Core.currencyHelper

    static func buyerStepOne(status: P2PPaymentOfferStatus,
                             listingPrice: Double,
                             currency: Currency,
                             withdrawnButtonTapHandler: ButtonTapHandler?) -> P2PPaymentsOfferStatusStepViewState {
        let formattedPrice = currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: listingPrice)
        let extraDescription: ExtraDescription? = {
            switch status {
            case .accepted, .declined, .completed, .error:
                return nil
            case .pending:
                return ExtraDescription(text: "Offer pending", style: .negative)
            case .canceled:
                return ExtraDescription(text: "Offer withdrawn", style: .negative)
            case .expired:
                return ExtraDescription(text: "Offer expired", style: .negative)
            }
        }()
        let buttonState: ButtonState? = {
            guard status == .pending else { return nil }
            return ButtonState(title: "Withdraw offer", tapHandler: withdrawnButtonTapHandler)
        }()
        return P2PPaymentsOfferStatusStepViewState(title: "You're offering \(formattedPrice)",
                                                   description: "letgo will securely hold your funds in escrow until you confirm you’ve received the item",
                                                   extraDescription: extraDescription,
                                                   buttonState: buttonState)
    }

    static func buyerStepTwo(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepViewState {
        let extraDescription: ExtraDescription? = {
            switch status {
            case .completed, .expired, .error, .pending, .canceled:
                return nil
            case .accepted:
                return ExtraDescription(text: "Offer accepted", style: .positive)
            case .declined:
                return ExtraDescription(text: "Offer declined", style: .negative)
            }
        }()
        return P2PPaymentsOfferStatusStepViewState(title: "The seller accepts",
                                                   description: "You’ll get a notification that the seller has accepted your offer",
                                                   extraDescription: extraDescription,
                                                   buttonState: nil)
    }

    static func buyerStepThree(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepViewState {
        return P2PPaymentsOfferStatusStepViewState(title: "Meet in person and release the payment",
                                                   description: "When you have the item, release the payment to the seller by sharing your payment code",
                                                   extraDescription: nil,
                                                   buttonState: nil)
    }

    static func sellerStepOne(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepViewState {
        let extraDescription: ExtraDescription? = {
            switch status {
            case .completed, .error, .pending:
                return nil
            case .accepted:
                return ExtraDescription(text: "Offer accepted", style: .positive)
            case .declined:
                return ExtraDescription(text: "Offer declined", style: .negative)
            case .canceled:
                return ExtraDescription(text: "Offer withdrawn", style: .negative)
            case .expired:
                return ExtraDescription(text: "Offer expired", style: .negative)
            }
        }()
        return P2PPaymentsOfferStatusStepViewState(title: "Accept the offer",
                                                   description: "A buyer’s offering to pay you securely through the letgo app. Act fast, their offer expires in 24 hours.",
                                                   extraDescription: extraDescription,
                                                   buttonState: nil)
    }

    static func sellerStepTwo() -> P2PPaymentsOfferStatusStepViewState {
        return P2PPaymentsOfferStatusStepViewState(title: "Meet in person and get paid",
                                                   description: "Give the item to the buyer, get their payment code and enter it in the app to receive your secure payment",
                                                   extraDescription: nil,
                                                   buttonState: nil)
    }
}
