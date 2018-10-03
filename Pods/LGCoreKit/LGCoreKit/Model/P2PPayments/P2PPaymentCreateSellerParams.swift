import Foundation

public struct P2PPaymentCreateSellerParams {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()

    let sellerId: String
    let firstName: String
    let lastName: String
    let address: String
    let countryCode: String
    let state: String
    let city: String
    let zipcode: String
    let birthDate: Date
    let ssnLastFour: String

    public init(sellerId: String,
                firstName: String,
                lastName: String,
                address: String,
                countryCode: String,
                state: String,
                city: String,
                zipcode: String,
                birthDate: Date,
                ssnLastFour: String) {
        self.sellerId = sellerId
        self.firstName = firstName
        self.lastName = lastName
        self.address = address
        self.countryCode = countryCode
        self.state = state
        self.city = city
        self.zipcode = zipcode
        self.birthDate = birthDate
        self.ssnLastFour = ssnLastFour
    }

    var apiParams: [String : Any] {
        let formattedDate = P2PPaymentCreateSellerParams.dateFormatter.string(from: birthDate)
        let attributes: [String : Any] = ["first_name": firstName,
                                          "last_name": lastName,
                                          "personal_address_line": address,
                                          "personal_address_country_code": countryCode,
                                          "personal_address_state": state,
                                          "personal_address_city": city,
                                          "personal_address_zipcode": zipcode,
                                          "billing_address_line": address,
                                          "billing_address_country_code": countryCode,
                                          "billing_address_state": state,
                                          "billing_address_city": city,
                                          "billing_address_zipcode": zipcode,
                                          "birth_date": formattedDate,
                                          "terms_of_service": true,
                                          "ssn_last_4": ssnLastFour]
        let data: [String : Any] = ["type": "sellers",
                                    "id": sellerId,
                                    "attributes": attributes]
        let params: [String : Any] = ["data" : data]
        return params
    }
}
