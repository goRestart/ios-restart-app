import LGCoreKit

extension Feed {
    var totalHorizontalItemCount: Int {
        return sections.map{ $0.items.count }.reduce(0, +)
    }
    
    var totalVerticalItemCount: Int {
        return items.count
    }
    
    var sectionsShown: [String] {
        return sections.map{ $0.id }
    }
}
