
import LGCoreKit

extension ServiceAttributes {
    
    func editedFieldsTracker(newServicesAttributes: ServiceAttributes?) -> [EventParameterEditedFields] {
        guard let newServicesAttributes = newServicesAttributes else { return [] }
        let stringsEquatables = [(typeId, newServicesAttributes.typeId, EventParameterEditedFields.serviceType),
                                 (subtypeId, newServicesAttributes.subtypeId, EventParameterEditedFields.serviceSubtype),
                                 (paymentFrequency?.rawValue, newServicesAttributes.paymentFrequency?.rawValue, EventParameterEditedFields.paymentFrequency)]
        let diffStrings = stringsEquatables.filter { $0.0 != $0.1 }.map { $0.2 }
        return diffStrings
    }
}
