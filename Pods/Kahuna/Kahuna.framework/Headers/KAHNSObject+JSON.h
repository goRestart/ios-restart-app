//
//  KAHNSObject+JSON.h
//  KahunaSDK
//

#import <Foundation/Foundation.h>

@interface NSObject (KahunaJSON)

- (NSString *)KahunaJSONRepresentation;

@end

@interface NSString (KahunaJSON)

- (id)KahunaJSONValue;

@end

@interface NSData (KahunaJSON)

- (id)KahunaJSONValue;

@end
