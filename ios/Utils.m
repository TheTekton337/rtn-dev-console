#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utils.h"

@implementation Utils

+ (NSString *)nsStringFromLogType:(LogType)logType {
    switch (logType) {
        case LogTypeWarning:
            return @"Warning";
        case LogTypeError:
            return @"Error";
        case LogTypeConnectionError:
            return @"ConnectionError";
        case LogTypeInfo:
        default:
            return @"Info";
    }
}

+ (LogType)logTypeFromNSString:(NSString *)string {
    if ([string isEqualToString:@"Warning"]) {
        return LogTypeWarning;
    } else if ([string isEqualToString:@"Error"]) {
        return LogTypeError;
    } else if ([string isEqualToString:@"ConnectionError"]) {
        return LogTypeConnectionError;
    } else {
        return LogTypeInfo;
    }
}

+ (NSString *)nsStringFromAuthMethod:(AuthMethod)authMethod {
    switch (authMethod) {
        case AuthMethodPubkeyFile:
            return @"PubkeyFile";
        case AuthMethodPubkeyMemory:
            return @"PubkeyMemory";
        case AuthMethodPassword:
        default:
            return @"Password";
    }
}

+ (AuthMethod)authMethodFromNSString:(NSString *)authMethodString {
    if ([authMethodString isEqualToString:@"PubkeyFile"]) {
        return AuthMethodPubkeyFile;
    } else if ([authMethodString isEqualToString:@"PubkeyMemory"]) {
        return AuthMethodPubkeyMemory;
    } else {
        return AuthMethodPassword;
    }
}

+ (NSString *)jsonStringFromData:(NSData *)data {
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!jsonObject) {
        @throw [NSException exceptionWithName:@"JSONConversionException"
                                       reason:@"Failed to parse NSData to JSON object."
                                     userInfo:@{@"error": error}];
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        @throw [NSException exceptionWithName:@"JSONConversionException"
                                       reason:@"Failed to serialize JSON object to NSData."
                                     userInfo:@{@"error": error}];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!jsonString) {
        @throw [NSException exceptionWithName:@"JSONConversionException"
                                       reason:@"Failed to create NSString from JSON NSData."
                                     userInfo:nil];
    }
    
    return jsonString;
}

+ (NSString *)jsonStringFromError:(NSError *)error {
    NSDictionary *errorDetails = @{
        @"domain": error.domain,
        @"code": @(error.code),
        @"userInfo": error.userInfo ?: @{}
    };
    
    NSError *serializationError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:errorDetails
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&serializationError];
    if (!jsonData) {
        @throw [NSException exceptionWithName:@"JSONConversionException"
                                       reason:@"Failed to parse NSError to JSON object."
                                     userInfo:@{@"error": serializationError}];
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if (!jsonString) {
        @throw [NSException exceptionWithName:@"JSONConversionException"
                                       reason:@"Failed to create NSString from JSON NSData."
                                     userInfo:nil];
    }
    
    return jsonString;
}

//+ (UIColor *)hexStringToColor:(NSString *)stringToConvert
//{
//    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
//    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];
//    
//    unsigned hex;
//    if (![stringScanner scanHexInt:&hex]) return nil;
//    int r = (hex >> 16) & 0xFF;
//    int g = (hex >> 8) & 0xFF;
//    int b = (hex) & 0xFF;
//    
//    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
//}

+ (BOOL)hexStringToUInt16:(UInt16 *)red green:(UInt16 *)green blue:(UInt16 *)blue fromString:(NSString *)stringToConvert {
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];
    
    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return NO;
    
    if (red) *red = ((hex >> 16) & 0xFF) * 257; // Scale 0..255 to 0..65535
    if (green) *green = ((hex >> 8) & 0xFF) * 257; // Scale 0..255 to 0..65535
    if (blue) *blue = (hex & 0xFF) * 257; // Scale 0..255 to 0..65535
    
    return YES;
}

// + objectToData:(id)object
// {
//   NSData *data = nil;
//   if (object) {
//     data = [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:NO error:nil];
//   }
//   return data;
// }

+ (id)alloc {
  [NSException raise:@"Cannot be instantiated!" format:@"Static class 'Utils' cannot be instantiated!"];
  return nil;
}

@end
