//
//  CommercializerTemplate+SequenceTypeHelper.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 5/4/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

extension Sequence where Iterator.Element == CommercializerTemplate {
    public func availableTemplates(_ commercializers: [Commercializer]) -> [CommercializerTemplate] {
        let doneTemplateIds = commercializers.flatMap { $0.templateId }
        return filter {
            guard let templateId = $0.objectId else { return false }
            return !doneTemplateIds.contains(templateId)
        }
    }
}
