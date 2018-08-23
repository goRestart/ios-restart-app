import Foundation
import IGListKit

//TODO: Change the structure to correct API definition when API is defined.

final class ListingSectionModel: ListDiffable {

    let id: String
    let type: String
    var title: String
    let links: [String: String]
    let items: [String] // TODO: Change to actual item definition of feed items when API is defined

    init(id: String,
         type: String,
         title: String,
         links: [String: String],
         items: [String]) {
        self.id = id
        self.type = type
        self.title = title
        self.links = links
        self.items = items
    }
    
    func diffIdentifier() -> NSObjectProtocol {
        return id as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self !== object else { return true }
        guard let object = object as? ListingSectionModel else { return false }
        return id == object.id &&
            type == object.type &&
            title == object.title &&
            links == object.links &&
            items == object.items
    }
}

enum ListingSectionType: String {
    case horizontal = "Horizontal-Section"
    case vertical = "Vertical-Section"
}

enum StaticSectionType: String {
    case categoryBubble = "categoryBubbleToken"
    case pushBanner = "pushBannerToken"
}

struct ListingSectionBuilder {
    
    static func buildListingSections(locationString: String) -> [ListingSectionModel] {
        let listingSectionModel1 = ListingSectionModel(id: "1",
                                                       type: ListingSectionType.horizontal.rawValue,
                                                       title: "Recommended for you",
                                                       links: ["View all": "b"],
                                                       items: ["a","b","c","d"])
        
        let listingSectionModel2 = ListingSectionModel(id: "2",
                                                       type: ListingSectionType.horizontal.rawValue,
                                                       title: "Hand picked for you",
                                                       links: ["See all": "b"],
                                                       items: ["a","b","c","d", "e", "f"])
        let fullListingSectionModel = ListingSectionModel(id: "3",
                                                          type: ListingSectionType.vertical.rawValue,
                                                          title: locationString,
                                                          links: ["Edit": "b"],
                                                          items: ["a","b","a","b","c","d","a","b","c","d","a","b","c","d"])
        
        return [listingSectionModel1, listingSectionModel2, fullListingSectionModel]
    }
}

/*
{
    "id": "1231231334320",
    "type": "some section type",
    "title": "Section title",
    "links": { "see_all": "letgo://popular_videos" },
    "items": [ ... ]
}
 
*/
