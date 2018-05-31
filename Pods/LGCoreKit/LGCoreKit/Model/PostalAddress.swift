import Foundation

public struct PostalAddress: Equatable, Decodable {
    
    public let address: String?
    public let city: String?
    public let zipCode: String?
    public let state: String?
    public let countryCode: String?
    public let country: String?
    
    // MARK: - Lifecycle
    
    public init(address: String?,
                city: String?,
                zipCode: String?,
                state: String?,
                countryCode: String?,
                country: String?) {
        
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.state = state
        self.countryCode = countryCode
        self.country = country
    }
    
    public static func emptyAddress() -> PostalAddress {
        return PostalAddress(address: nil,
                               city: nil,
                               zipCode: nil,
                               state: nil,
                               countryCode: nil,
                               country: nil)
    }
    
    // MARK: - Decodable
    
    /*
     {
        "address": "Superhero ave, 3",
        "zip_code": "33948",
        "city": "Gotham",
        "state": "Quieto"
        "country_code": "ES",
        "country": "España"
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainerSnakeCase = try decoder.container(keyedBy: CodingKeysSnakeCase.self)
        let keyedContainerCamelCase = try decoder.container(keyedBy: CodingKeysCamelCase.self)
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        address = try keyedContainer.decodeIfPresent(String.self, forKey: .address)
        city = try keyedContainer.decodeIfPresent(String.self, forKey: .city)

        
        if let zipCodeValue = try keyedContainerSnakeCase.decodeIfPresent(String.self, forKey: .zipCode) {
            zipCode = zipCodeValue
        } else {
          zipCode = try keyedContainerCamelCase.decodeIfPresent(String.self, forKey: .zipCode)
        }
        
        state = try keyedContainer.decodeIfPresent(String.self, forKey: .state)
        
        if let countryCodeValue = try keyedContainerSnakeCase.decodeIfPresent(String.self, forKey: .countryCode) {
            countryCode = countryCodeValue
        } else {
            countryCode = try keyedContainerCamelCase.decodeIfPresent(String.self, forKey: .countryCode)
        }
        
        country = try keyedContainer.decodeIfPresent(String.self, forKey: .country)
    }
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
        case city = "city"
        case state = "state"
        case country = "country"
    }
    
    enum CodingKeysSnakeCase: String, CodingKey {
        case zipCode = "zip_code"
        case countryCode = "country_code"
    }
    
    enum CodingKeysCamelCase: String, CodingKey {
        case zipCode = "zipCode"
        case countryCode = "countryCode"
    }
    
    // MARK: Equatable
    
    public static func ==(lhs: PostalAddress, rhs: PostalAddress) -> Bool {
        return lhs.address == rhs.address &&
            lhs.city == rhs.city &&
            lhs.zipCode == rhs.zipCode &&
            lhs.state == rhs.state &&
            lhs.countryCode == rhs.countryCode &&
            lhs.country == rhs.country
    }
}
