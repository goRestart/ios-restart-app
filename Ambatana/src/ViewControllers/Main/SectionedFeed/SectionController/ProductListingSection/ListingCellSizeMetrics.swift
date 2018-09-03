import LGComponents

struct ListingCellSizeMetrics {
    
    private static let cellMinHeight: CGFloat = 80.0
    
    private var cellAspectRatio: CGFloat {
        return 198.0 / ListingCellSizeMetrics.cellMinHeight
    }
    
    private var cellHeight: CGFloat {
        return cellWidth * cellAspectRatio
    }
    
    private let numberOfColumns: Int
    
    init(numberOfColumns: Int) {
        self.numberOfColumns = numberOfColumns
    }
    
    var defaultCellSize: CGSize {
        return CGSize(width: cellWidth,
                      height: cellHeight)
    }
    
    var cellWidth: CGFloat {
        let leftInset = SectionControllerLayout.sectionInset.left
        let rightInset = SectionControllerLayout.sectionInset.right
        let interItemSpacing = CGFloat(numberOfColumns - 1) * SectionControllerLayout.fixedListingSpacing
        return (UIScreen.main.bounds.size.width - leftInset - rightInset - interItemSpacing) / CGFloat(numberOfColumns)
    }
    
    var buttonHeight: CGFloat {
        return numberOfColumns == 3 ? LGUIKitConstants.smallButtonHeight : LGUIKitConstants.mediumButtonHeight
    }
    
    func cellAdaptedSize(fromOriginalCellSize orinalSize: CGSize) -> CGSize {
        return orinalSize.adaptSize(withWidthSize: cellWidth, maxHeight: ListingCellSizeMetrics.cellMinHeight)
    }
}
