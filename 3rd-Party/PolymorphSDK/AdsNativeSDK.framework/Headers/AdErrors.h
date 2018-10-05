//
//  AdErrors.h
//  AdsNative-iOS-SDK
//
//  Created by Arvind Bharadwaj on 23/09/15.
//  Copyright (c) 2015 AdsNative. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum AdErrorCode {
    
    AdErrorUnknown = -1,
    
    AdErrorImageDownloadFailed = -1001,
    AdErrorInvalidServerResponse = -1002,
    AdErrorHTTPError = -1003,
    AdErrorNoInventory = -1004,
    AdErrorContentDisplayError = -1005
    
} AdErrorCode;

extern NSString * const AdsNativeSDKDomain;

NSError *AdNSErrorForInvalidAdServerResponse(NSString *reason);
NSError *AdNSErrorForImageDownloadFailure();
NSError *AdNSErrorForInvalidImageURL();
NSError *AdNSErrorForNetworkConnectionError();
NSError *AdNSErrorForNoFill();
NSError *AdNSErrorForContentDisplayErrorMissingRootController();
NSError *AdNSErrorForContentDisplayErrorInvalidURL();