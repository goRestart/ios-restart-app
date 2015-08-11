#import <Foundation/Foundation.h>

@protocol NANRequestObserver <NSObject>
/*
 * If error is nil, the request was completed successfully - otherwise error will contain
 * details of the problem encountered.
 */
- (void)request:(NSURLRequest *)request
completedWithError:(NSError *)error;

@end


@interface NANTracking : NSObject

/*
 * Off by default. Set to true to enable test mode.
 */
+ (void)setDebugMode:(BOOL)debugMode;

/*
 * Call this with your Nanigans App Id. You need to call this method with 
 * corresponding arguments for the SDK to work.
 */
+ (void)setNanigansAppId:(NSString *)nanAppId
                 fbAppId:(NSString *)fbAppId;


/* 
 * Use this method to pass in a login-level user id.
 */
+ (void)setUserId:(NSString *)userId;

+(void)setDebugHost:(NSString *)host;

/*
 * Adds the given object to the list of observers and retains it.
 * Remember to call +removeRequestObserver in order to release it.
 */
+ (void)registerRequestObserver:(id<NANRequestObserver>)observer;

/*
 * Removes the given object from the list of request observers.
 */
+ (void)removeRequestObserver:(id<NANRequestObserver>)observer;

/* 
 * This is the most generic tracking method. You can use it to track events outside
 * the several basic ones we have provided helper methods for.
 * eventType needs to have one of the following values:
 * user, install, purchase, visit, viral
 */
+ (void)trackNanigansEvent:(NSString *)eventType
                      name:(NSString *)eventName
               extraParams:(NSDictionary *)extraParams;

/*
 * You should call this method every time your app is launched or brought to foreground.
 * If a URL was passed in to the app, you should forward it to this method. It tries
 * to find nan_pid value in the query parameters, and will return it if found. Otherwise,
 * returns nil.
 */
+ (NSString *)trackAppLaunch:(NSURL *)launchURL;

/*
 * Like +(NSString *)trackAppLaunch:, but accepts arbitrary additional parameters.
 */
+ (NSString *)trackAppLaunch:(NSURL *)launchURL
                 extraParams:(NSDictionary *)extraParams;

/*
 * Track user registration event. Pass in the user id, this method will call 
 * setUserId: with it.
 */
+ (void)trackUserRegistration:(NSString *)userId;

/*
 * Like +(void)trackUserRegistration:, but accepts arbitrary additional parameters.
 */
+ (void)trackUserRegistration:(NSString *)userId
                  extraParams:(NSDictionary *)extraParams;

/* 
 * Track user login event. Pass in the user id, this method will call setUserId: with it.
 */
+ (void)trackUserLogin:(NSString *)userId;

/*
 * Like +(void)trackUserLogin:, but accepts arbitrary additional parameters.
 */
+ (void)trackUserLogin:(NSString *)userId
           extraParams:(NSDictionary *)extraParams;

/*
 * Track adding a product to cart.
 */
+ (void)trackAddSingleProductToCart:(NSString *)sku
                              value:(int)value
                           currency:(NSString *)currency
                           quantity:(int)quantity;

/*
 * Like +(void)trackSingleProductToCart:value:quantity:, but accepts arbitrary additional parameters.
 */
+ (void)trackAddSingleProductToCart:(NSString *)sku
                              value:(int)value
                           currency:(NSString *)currency
                           quantity:(int)quantity
                        extraParams:(NSDictionary *)extraParams;


/*
 * Track adding multiple products to cart.
 */
+ (void)trackAddMultipleProductsToCart:(NSArray *)skus
                                values:(NSArray *)values
                              currencies:(NSArray *)currencies
                            quantities:(NSArray *)quantities;

/*
 * Like +(void)trackAddMultipleProductsToCart:values:quantities:, but accepts arbitrary additional parameters.
 */
+ (void)trackAddMultipleProductsToCart:(NSArray *)skus
                                values:(NSArray *)values
                              currencies:(NSArray *)currencies
                            quantities:(NSArray *)quantities
                           extraParams:(NSDictionary *)extraParams;

/*
 * Track the purchase of a single product. 
 */
+ (void)trackSingleProductPurchase:(NSString *)sku
                             value:(int)value
                          currency:(NSString *)currency
                          quantity:(int)quantity;


/*
 * Like +(void)trackSingleProductPurchase:value:quantity:, but accepts arbitrary additional parameters.
 */
+ (void)trackSingleProductPurchase:(NSString *)sku
                             value:(int)value
                          currency:(NSString *)currency
                          quantity:(int)quantity
                       extraParams:(NSDictionary *)extraParams;

/*
 * Track the purchase of multiple products.
 */
+ (void)trackMultipleProductsPurchase:(NSArray *)skus
                               values:(NSArray *)values
                             currencies:(NSArray *)currencies
                           quantities:(NSArray *)quantities;


/*
 * Like +(void)trackMultipleProductsPurchase:values:quantities:, but accepts arbitrary additional parameters.
 */
+ (void)trackMultipleProductsPurchase:(NSArray *)skus
                               values:(NSArray *)values
                             currencies:(NSArray *)currencies
                           quantities:(NSArray *)quantities
                          extraParams:(NSDictionary *)extraParams;

#pragma mark Old API - don't use in new code

+ (void)trackNanigansEvent:(NSString *)uid
                      type:(NSString *)type
                      name:(NSString *)name;
    
+ (void)trackNanigansEvent:(NSString *)uid
                      type:(NSString *)type
                      name:(NSString *)name
                     value:(NSString *)value;
    
+ (void)trackNanigansEvent:(NSString *)uid
                      type:(NSString *)type
                      name:(NSString *)name
               extraParams:(NSDictionary *)extraParams;
    
@end
