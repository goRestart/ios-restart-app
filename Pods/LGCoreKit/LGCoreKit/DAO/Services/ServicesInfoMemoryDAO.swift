final class ServicesInfoMemoryDAO: ServicesInfoDAO, ServicesInfoRetrievable {

    private var serviceTypesList: [ServiceType] = []
    
    var servicesTypes: [ServiceType] {
        return serviceTypesList
    }
    
    func save(servicesInfo: [ServiceType]) {
        serviceTypesList = servicesInfo
    }
    
    func serviceSubtypes(forServiceTypeId serviceTypeId: String) -> [ServiceSubtype] {
        return serviceType(forServiceTypeId: serviceTypeId)?.subTypes ?? []
    }
    
    func serviceType(forServiceTypeId serviceTypeId: String) -> ServiceType? {
        return servicesTypes.first(where: { $0.id == serviceTypeId })
    }
    
    func serviceSubtype(forServiceSubtypeId serviceSubtypeId: String) -> ServiceSubtype? {
        return servicesTypes.flatMap({ $0.subTypes }).first(where: { $0.id == serviceSubtypeId })
    }
    
    func clean() {
        serviceTypesList = []
    }
    
    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        guard serviceTypesList.isEmpty else { return }
        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonServiceTypesList = try JSONSerialization.jsonObject(with: data,
                                                                        options: [])
            guard let serviceTypesList = decoder(jsonServiceTypesList) else { return }
            save(servicesInfo: serviceTypesList)
        } catch {
            logMessage(.verbose,
                       type: CoreLoggingOptions.database,
                       message: "Failed to create Services Info first run memory cache: \(error)")
        }
    }
}


// MARK:- Decoder implementation
extension ServicesInfoMemoryDAO {
    
    private func decoder(_ object: Any) -> [ServiceType]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        do {
            let serviceTypes = try JSONDecoder().decode(FailableDecodableArray<LGServiceType>.self, from: data)
            return serviceTypes.validElements
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse LGServiceType \(object)")
        }
        return nil
    }
}
