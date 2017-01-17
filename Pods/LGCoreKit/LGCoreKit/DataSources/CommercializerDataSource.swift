//
//  CommercializerDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 2/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result


typealias CommercializerDataSourceTemplateResult = Result<CommercializerTemplatesByCountry, ApiError>
typealias CommercializerDataSourceTemplateCompletion = (CommercializerDataSourceTemplateResult) -> Void

typealias CommercializerDataSourceResult = Result<Commercializer, ApiError>
typealias CommercializerDataSourceCompletion = (CommercializerDataSourceResult) -> Void

typealias CommercializersDataSourceResult = Result<[Commercializer], ApiError>
typealias CommercializersDataSourceCompletion = (CommercializersDataSourceResult) -> Void

typealias CommercializerDataSourceProductsResult = Result<[CommercializerProduct], ApiError>
typealias CommercializerDataSourceProductsCompletion = (CommercializerDataSourceProductsResult) -> Void

protocol CommercializerDataSource {
    func indexTemplates(_ completion: CommercializerDataSourceTemplateCompletion?)
    func index(_ productId: String, completion: CommercializersDataSourceCompletion?)
    func create(_ productId: String, templateId: String, completion: CommercializerDataSourceCompletion?)
    func indexAvailableProducts(_ userId: String, completion: CommercializerDataSourceProductsCompletion?)
}
