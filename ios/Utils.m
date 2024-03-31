#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Utils.h"

@implementation Utils

+ (UIColor *)hexStringToColor:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];
    
    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

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

+ objectToData:(id)object
{
  NSData *data = nil;
  if (object) {
    data = [NSKeyedArchiver archivedDataWithRootObject:data requiringSecureCoding:NO error:nil];
  }
  return data;
}

+ (id)alloc {
  [NSException raise:@"Cannot be instantiated!" format:@"Static class 'Utils' cannot be instantiated!"];
  return nil;
}

@end
