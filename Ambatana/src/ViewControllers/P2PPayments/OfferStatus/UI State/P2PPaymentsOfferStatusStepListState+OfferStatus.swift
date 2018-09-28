import Foundation
import LGCoreKit
import LGComponents


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
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsBuyerBuyerOfferStepStatusPending, style: .negative)
            case .canceled:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsBuyerBuyerOfferStepStatusWithdrawn, style: .negative)
            case .expired:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsBuyerBuyerOfferStepStatusExpired, style: .negative)
            }
        }()
        let buttonState: ButtonState? = {
            guard status == .pending else { return nil }
            return ButtonState(title: R.Strings.paymentsOfferStatusAsBuyerBuyerOfferStepWithdrawButton, tapHandler: withdrawnButtonTapHandler)
        }()
        return P2PPaymentsOfferStatusStepViewState(title: R.Strings.paymentsOfferStatusAsBuyerBuyerOfferStepTitle(formattedPrice),
                                                   description: R.Strings.paymentsOfferStatusAsBuyerBuyerOfferStepDescription,
                                                   extraDescription: extraDescription,
                                                   buttonState: buttonState)
    }

    static func buyerStepTwo(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepViewState {
        let extraDescription: ExtraDescription? = {
            switch status {
            case .completed, .expired, .error, .pending, .canceled:
                return nil
            case .accepted:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsBuyerSellerOfferStepStatusAccepted, style: .positive)
            case .declined:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsBuyerSellerOfferStepStatusDeclined, style: .negative)
            }
        }()
        return P2PPaymentsOfferStatusStepViewState(title: R.Strings.paymentsOfferStatusAsBuyerSellerOfferStepTitle,
                                                   description: R.Strings.paymentsOfferStatusAsBuyerSellerOfferStepDescription,
                                                   extraDescription: extraDescription,
                                                   buttonState: nil)
    }

    static func buyerStepThree(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepViewState {
        return P2PPaymentsOfferStatusStepViewState(title: R.Strings.paymentsOfferStatusAsBuyerMeetingStepTitle,
                                                   description: R.Strings.paymentsOfferStatusAsBuyerMeetingStepDescription,
                                                   extraDescription: nil,
                                                   buttonState: nil)
    }

    static func sellerStepOne(status: P2PPaymentOfferStatus) -> P2PPaymentsOfferStatusStepViewState {
        let extraDescription: ExtraDescription? = {
            switch status {
            case .completed, .error, .pending:
                return nil
            case .accepted:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsSellerBuyerOfferStatusAccepted, style: .positive)
            case .declined:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsSellerBuyerOfferStatusDeclined, style: .negative)
            case .canceled:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsSellerBuyerOfferStatusWithdrawn, style: .negative)
            case .expired:
                return ExtraDescription(text: R.Strings.paymentsOfferStatusAsSellerBuyerOfferStatusExpired, style: .negative)
            }
        }()
        return P2PPaymentsOfferStatusStepViewState(title: R.Strings.paymentsOfferStatusAsSellerBuyerOfferTitle,
                                                   description: R.Strings.paymentsOfferStatusAsSellerBuyerOfferDescription,
                                                   extraDescription: extraDescription,
                                                   buttonState: nil)
    }

    static func sellerStepTwo() -> P2PPaymentsOfferStatusStepViewState {
        return P2PPaymentsOfferStatusStepViewState(title: R.Strings.paymentsOfferStatusAsSellerMeetingTitle,
                                                   description: R.Strings.paymentsOfferStatusAsSellerMeetingDescription,
                                                   extraDescription: nil,
                                                   buttonState: nil)
    }
}
