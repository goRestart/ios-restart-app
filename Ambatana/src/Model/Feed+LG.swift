import LGCoreKit

extension Feed {
    var isEmpty: Bool {
        return sections.isEmpty && items.isEmpty
    }
    
    var isFirstPage: Bool {
        return pagination.previous == nil
    }
    
    var isLastPage: Bool {
        return pagination.next == nil
    }
}

