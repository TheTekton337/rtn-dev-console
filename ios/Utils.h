#ifndef Utils_h
#define Utils_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LogType) {
    LogTypeInfo,
    LogTypeWarning,
    LogTypeError,
    LogTypeConnectionError,
};

typedef NS_ENUM(NSInteger, AuthMethod) {
    AuthMethodPassword,
    AuthMethodPubkeyFile,
    AuthMethodPubkeyMemory,
//    AuthMethodPubkeyInteractive,
};

@interface Utils : NSObject
+ (NSString *)jsonStringFromData:(NSData *)data;
+ (NSString *)jsonStringFromError:(NSError *)error;
+ (LogType)logTypeFromNSString:(NSString *)logType;
+ (NSString *)nsStringFromLogType:(LogType)logType;
+ (NSString *)nsStringFromAuthMethod:(AuthMethod)authMethod;
//+ (UIColor *)hexStringToColor:(NSString *)stringToConvert;
+ (BOOL)hexStringToUInt16:(UInt16 *)red green:(UInt16 *)green blue:(UInt16 *)blue fromString:(NSString *)stringToConvert;
// + objectToData:(id)object;
@end

#endif /* Utils_h */
