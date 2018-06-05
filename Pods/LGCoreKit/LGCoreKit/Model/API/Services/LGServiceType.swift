import Foundation

struct LGServiceType: ServiceType, Decodable {
    let id: String
    let name: String
    let subTypes: [ServiceSubtype]
    
    public init(id: String,
                name: String,
                subtypes: [ServiceSubtype]) {
        self.id = id
        self.name = name
        self.subTypes = subtypes
    }
    
    // MARK:- Decodable

    /*
         {
             "id": "2540d272-b65e-4b8d-bb24-28cb35f038f5",
             "name": "Photography",
             "subTypes": [ ... ]
         }
     */

    public init(from decoder: Decoder) throws {
        
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try keyedContainer.decode(String.self,
                                            forKey: .id)
        
        self.name = try keyedContainer.decode(String.self,
                                              forKey: .name)
        
        self.subTypes = try keyedContainer.decode(FailableDecodableArray<LGServiceSubtype>.self,
                                                  forKey: .subTypes).validElements
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, subTypes
    }
}
