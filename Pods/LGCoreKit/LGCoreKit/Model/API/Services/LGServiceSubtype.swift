import Foundation

struct LGServiceSubtype: ServiceSubtype, Decodable {
    let id: String
    let name: String
    let isHighlighted: Bool
    
    public init(id: String,
                name: String,
                isHighlighted: Bool) {
        self.id = id
        self.name = name
        self.isHighlighted = isHighlighted
    }
    
    // MARK:- Decodable
    /*
     {
         "id": "dc2b8747-54df-4c52-bbe6-40a380744093",
         "name": "Wedding photography",
         "isHighlighted": true
     }
     */
    
    public init(from decoder: Decoder) throws {
        
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try keyedContainer.decode(String.self,
                                            forKey: .id)
        
        self.name = try keyedContainer.decode(String.self,
                                              forKey: .name)
        
        self.isHighlighted = try keyedContainer.decode(Bool.self,
                                                       forKey: .isHighlighted)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, isHighlighted
    }
}
