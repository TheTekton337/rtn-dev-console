#ifndef Utils_h
#define Utils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject
+ (UIColor *)hexStringToColor:(NSString *)stringToConvert;
+ (BOOL)hexStringToUInt16:(UInt16 *)red green:(UInt16 *)green blue:(UInt16 *)blue fromString:(NSString *)stringToConvert;
+ objectToData:(id)object;
@end

#endif /* Utils_h */
