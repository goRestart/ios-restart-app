//
//  TaxonomiesRealmDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 18/07/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import RealmSwift
import Argo

class RealmTaxonomy: Object {
    dynamic var taxonomyName: String = ""
    dynamic var taxonomyIcon: String = ""
    let children = List<RealmTaxonomyChild>()
}

class RealmTaxonomyChild: Object {
    dynamic var taxonomyChildId: Int = 0
    dynamic var taxonomyChildType: String = ""
    dynamic var taxonomyChildName: String = ""
    let taxonomyChildHighlightOrder = RealmOptional<Int>()
    dynamic var taxonomyChildHighlightIcon: String?
    dynamic var taxonomyChildImage: String?
}

class TaxonomiesRealmDAO: TaxonomiesDAO {

    static let dataBaseName = "Taxonomies"
    static let dataBaseExtension = "realm"

    let dataBase: Realm

    var taxonomies: [Taxonomy] {
        let taxonomies = dataBase.objects(RealmTaxonomy.self)
        let rmTaxonomiesArray = Array(taxonomies)
        return rmTaxonomiesArray.map { convertToLGTaxonomy(taxonomy: $0) }
    }


    // MARK: - Lifecycle

    init(realm: Realm) {
        self.dataBase = realm
    }

    convenience init?() {

        guard let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                           .userDomainMask, true).first else { return nil }
        let cacheFilePath = cacheDirectoryPath + "/\(TaxonomiesRealmDAO.dataBaseName).\(TaxonomiesRealmDAO.dataBaseExtension)"

        do {
            let cacheFileUrl = URL(fileURLWithPath: cacheFilePath, isDirectory: false)
            let config = Realm.Configuration(fileURL: cacheFileUrl,
                                             readOnly: false,
                                             objectTypes: [RealmTaxonomy.self, RealmTaxonomyChild.self])

            let dataBase = try Realm(configuration: config)
            self.init(realm: dataBase)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not create Taxonomies DB: \(error)")
            return nil
        }
    }

    func save(taxonomies: [Taxonomy]) {
        clean()

        let realmArray = taxonomies.map { convertToRealmTaxonomy(taxonomy: $0) }
        let realmList = RealmHelper.convertArrayToRealmList(inputArray: realmArray)
        dataBase.cancelWriteTransactionsIfNeeded()

        do {
            try dataBase.write ({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dataBase.add(realmList)
            })
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not write in Taxonomies DB: \(error)")
        }
    }

    func clean() {
        dataBase.cancelWriteTransactionsIfNeeded()
        do {
            try dataBase.write ({ [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dataBase.deleteAll()
            })
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Could not clean the Taxonomies DB: \(error)")
        }
    }

    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        guard dataBase.objects(RealmTaxonomy.self).isEmpty else { return }

        do {
            let data = try Data(contentsOf: jsonURL)
            let jsonTaxonomiesList = try JSONSerialization.jsonObject(with: data, options: [])
            guard let taxonomiesList = decoderArray(jsonTaxonomiesList) else { return }
            save(taxonomies: taxonomiesList)
        } catch let error {
            logMessage(.verbose, type: CoreLoggingOptions.database, message: "Failed to create Taxonomies first run cache: \(error)")
        }
    }


    // MARK: - Private Methods

    // Realm to LG

    fileprivate func convertToRealmTaxonomy(taxonomy: Taxonomy) -> RealmTaxonomy {
        let resultTaxonomy = RealmTaxonomy()
        resultTaxonomy.taxonomyName = taxonomy.name
        resultTaxonomy.taxonomyIcon = taxonomy.icon?.absoluteString ?? ""
        let realmTaxonomyChildren = taxonomy.children.map { convertToRealmTaxonomyChild(taxonomyChild: $0) }
        resultTaxonomy.children.append(objectsIn: realmTaxonomyChildren)
        return resultTaxonomy
    }

    fileprivate func convertToRealmTaxonomyChild(taxonomyChild: TaxonomyChild) -> RealmTaxonomyChild {
        let resultTaxonomyChild = RealmTaxonomyChild()
        resultTaxonomyChild.taxonomyChildId = taxonomyChild.id
        resultTaxonomyChild.taxonomyChildType = taxonomyChild.type.rawValue
        resultTaxonomyChild.taxonomyChildName = taxonomyChild.name
        resultTaxonomyChild.taxonomyChildHighlightOrder.value = taxonomyChild.highlightOrder
        resultTaxonomyChild.taxonomyChildHighlightIcon = taxonomyChild.highlightIcon?.absoluteString
        resultTaxonomyChild.taxonomyChildImage = taxonomyChild.image?.absoluteString
        return resultTaxonomyChild
    }


    // LG to Realm

    fileprivate func convertToLGTaxonomy(taxonomy: RealmTaxonomy) -> LGTaxonomy {
        let resultTaxonomy = LGTaxonomy(name: taxonomy.taxonomyName,
                                        icon: taxonomy.taxonomyIcon,
                                        children: Array(taxonomy.children).map { convertToLGTaxonomyChild(taxonomyChild: $0) })
        return resultTaxonomy
    }

    fileprivate func convertToLGTaxonomyChild(taxonomyChild: RealmTaxonomyChild) -> LGTaxonomyChild {
        let resultChild = LGTaxonomyChild(id: taxonomyChild.taxonomyChildId,
                                          type: taxonomyChild.taxonomyChildType,
                                          name: taxonomyChild.taxonomyChildName,
                                          highlightOrder: taxonomyChild.taxonomyChildHighlightOrder.value,
                                          highlightIcon: taxonomyChild.taxonomyChildHighlightIcon,
                                          image: taxonomyChild.taxonomyChildImage)
        return resultChild
    }

    private func decoderArray(_ object: Any) -> [Taxonomy]? {
        guard let taxonomies = Array<LGTaxonomy>.filteredDecode(JSON(object)).value else { return nil }
        return taxonomies
    }
}
