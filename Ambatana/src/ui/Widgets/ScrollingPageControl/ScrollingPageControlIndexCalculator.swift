
struct ScrollingPageControlIndexCalculator {
    
    private let smallIndexOffset: Int
    private let tinyIndexOffset: Int
    private let selectedIndex: Int
    private let currentScrollDirection: ScrollingPageControl.Direction
    private let directionChangeSourcePage: Int
    private let adjacentIndexThreshold: Int
    
    init(smallIndexOffset: Int,
         tinyIndexOffset: Int,
         selectedIndex: Int,
         currentScrollDirection: ScrollingPageControl.Direction,
         directionChangeSourcePage: Int,
         adjacentIndexThreshold: Int) {
        
        self.smallIndexOffset = smallIndexOffset
        self.tinyIndexOffset = tinyIndexOffset
        self.selectedIndex = selectedIndex
        self.currentScrollDirection = currentScrollDirection
        self.directionChangeSourcePage = directionChangeSourcePage
        self.adjacentIndexThreshold = adjacentIndexThreshold
    }
    
    var adjacentIndexes: [Int] {
        switch currentScrollDirection {
        case .down:
            if selectedIndex == directionChangeSourcePage {
                return [selectedIndex+1, selectedIndex+2]
            }
            else if selectedIndex == directionChangeSourcePage+1 {
                return [selectedIndex-1, selectedIndex+1]
            }
            guard directionChangeSourcePage <= selectedIndex else { return [] }
            return [Int](directionChangeSourcePage...selectedIndex)
                .filter({ $0 >= selectedIndex-adjacentIndexThreshold })
        case .up:
            if selectedIndex == directionChangeSourcePage {
                return [selectedIndex-1, selectedIndex-2]
            }
            else if selectedIndex == directionChangeSourcePage-1 {
                return [selectedIndex-1, selectedIndex+1]
            }
            guard selectedIndex <= directionChangeSourcePage else { return [] }
            return [Int](selectedIndex...directionChangeSourcePage)
                .filter({ $0 <= selectedIndex+adjacentIndexThreshold })
        }
    }
    
    var smallIndexes: [Int] {
        return adjacentIndexes.offsetBounds(by: smallIndexOffset)
    }
    
    var tinyIndexes: [Int] {
        return adjacentIndexes.offsetBounds(by: tinyIndexOffset)
    }
}
