import Foundation
import LGCoreKit

protocol ProfessionalDealerAskPhoneNavigator {
    func closeAskPhoneFor(listing: Listing,
                          openChat: Bool,
                          withPhoneNum: String?,
                          source: EventParameterTypePage,
                          interlocutor: User?)
}
