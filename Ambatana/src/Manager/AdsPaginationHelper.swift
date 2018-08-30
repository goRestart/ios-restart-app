import LGComponents

private typealias AdsPagination = (adsPositions: [Int] , nextAdOffset: Int)

final class AdsPaginationHelper {
    
    private let featureFlags: FeatureFlaggeable
    private var previousAdOffset = 0
    private var isFirstPage = true
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
    }
    
    func adIndexesPositions(withItemListCount itemListCount: Int) -> [Int] {
        let positionsWithOffset = positionsAndOffset(itemListCount)
        let nextOffset = positionsWithOffset.nextAdOffset
        let adsPositions = positionsWithOffset.adsPositions
        
        previousAdOffset = nextOffset
        isFirstPage = false
        return adsPositions
    }
    
    func reset() {
        previousAdOffset = 0
        isFirstPage = true
    }
    
    //  MARK: - Private
    
    private func positionsAndOffset(_ itemListCount: Int) -> AdsPagination {
        
        var positions: [Int] = []
        
        guard adRatioIndex <= itemListCount else { return (adsPositions: positions, nextAdOffset: 0) }
        
        var positionToAddAd = isFirstPage ? SharedConstants.Feed.adInFeedInitialPosition : max(adRatioIndex - previousAdOffset, 0)
        
        positions.append(positionToAddAd)
        
        for _ in positionToAddAd...itemListCount {
            
            let nextAdPosition = positionToAddAd+adRatioIndex
            
            guard nextAdPosition < itemListCount else { break }
            
            positionToAddAd = nextAdPosition
            positions.append(nextAdPosition)
        }
        return (adsPositions: positions, nextAdOffset: itemListCount-positionToAddAd)
    }
    
    private var adRatioIndex: Int {
        if featureFlags.showAdsInFeedWithRatio.isActive {
            return featureFlags.showAdsInFeedWithRatio.ratio - 1
        } else {
            return SharedConstants.Feed.adsInFeedRatio - 1
        }
    }
    
}
