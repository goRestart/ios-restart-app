#ifdef __OBJC__
#import <UIKit/UIKit.h>
#endif

#import "BNCCallbacks.h"
#import "BNCConfig.h"
#import "BNCContentDiscoveryManager.h"
#import "BNCDeviceInfo.h"
#import "BNCEncodingUtils.h"
#import "BNCError.h"
#import "BNCFabricAnswers.h"
#import "BNCLinkCache.h"
#import "BNCLinkData.h"
#import "BNCPreferenceHelper.h"
#import "BNCServerInterface.h"
#import "BNCServerRequestQueue.h"
#import "BNCServerResponse.h"
#import "BNCStrongMatchHelper.h"
#import "BNCSystemObserver.h"
#import "Branch.h"
#import "BranchActivityItemProvider.h"
#import "BranchConstants.h"
#import "BranchContentDiscoverer.h"
#import "BranchContentDiscoveryManifest.h"
#import "BranchContentPathProperties.h"
#import "BranchCSSearchableItemAttributeSet.h"
#import "BranchDeepLinkingController.h"
#import "BranchLinkProperties.h"
#import "BranchUniversalObject.h"
#import "BranchView.h"
#import "BranchViewHandler.h"
#import "BNCServerRequest.h"
#import "BranchCloseRequest.h"
#import "BranchCreditHistoryRequest.h"
#import "BranchInstallRequest.h"
#import "BranchLoadRewardsRequest.h"
#import "BranchLogoutRequest.h"
#import "BranchOpenRequest.h"
#import "BranchRedeemRewardsRequest.h"
#import "BranchRegisterViewRequest.h"
#import "BranchSetIdentityRequest.h"
#import "BranchShortUrlRequest.h"
#import "BranchShortUrlSyncRequest.h"
#import "BranchSpotlightUrlRequest.h"
#import "BranchUserCompletedActionRequest.h"
#import "PromoViewHandler.h"
#import "BNCCallbacks.h"
#import "BNCConfig.h"
#import "BNCContentDiscoveryManager.h"
#import "BNCDeviceInfo.h"
#import "BNCEncodingUtils.h"
#import "BNCError.h"
#import "BNCFabricAnswers.h"
#import "BNCLinkCache.h"
#import "BNCLinkData.h"
#import "BNCPreferenceHelper.h"
#import "BNCServerInterface.h"
#import "BNCServerRequestQueue.h"
#import "BNCServerResponse.h"
#import "BNCStrongMatchHelper.h"
#import "BNCSystemObserver.h"
#import "Branch.h"
#import "BranchActivityItemProvider.h"
#import "BranchConstants.h"
#import "BranchContentDiscoverer.h"
#import "BranchContentDiscoveryManifest.h"
#import "BranchContentPathProperties.h"
#import "BranchCSSearchableItemAttributeSet.h"
#import "BranchDeepLinkingController.h"
#import "BranchLinkProperties.h"
#import "BranchUniversalObject.h"
#import "BranchView.h"
#import "BranchViewHandler.h"
#import "BNCServerRequest.h"
#import "BranchCloseRequest.h"
#import "BranchCreditHistoryRequest.h"
#import "BranchInstallRequest.h"
#import "BranchLoadRewardsRequest.h"
#import "BranchLogoutRequest.h"
#import "BranchOpenRequest.h"
#import "BranchRedeemRewardsRequest.h"
#import "BranchRegisterViewRequest.h"
#import "BranchSetIdentityRequest.h"
#import "BranchShortUrlRequest.h"
#import "BranchShortUrlSyncRequest.h"
#import "BranchSpotlightUrlRequest.h"
#import "BranchUserCompletedActionRequest.h"
#import "PromoViewHandler.h"

FOUNDATION_EXPORT double BranchVersionNumber;
FOUNDATION_EXPORT const unsigned char BranchVersionString[];

