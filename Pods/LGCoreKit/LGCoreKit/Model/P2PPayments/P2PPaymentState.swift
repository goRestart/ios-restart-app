import Foundation

public enum P2PPaymentState: String, Decodable {
 
  // Buyer
  case makeOffer = "make_offer"
  case viewPayCode = "view_pay_code"
  case offersUnavailable = "offers_unavailable"
  
  // Seller
  case viewOffer = "view_offer"
  case exchangeCode = "exchange_code"
  case payout = "payout"
}
