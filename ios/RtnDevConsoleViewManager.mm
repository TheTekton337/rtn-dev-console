#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import <React/RCTBridge.h>
// #import "Utils.h"

@interface RtnDevConsoleViewManager : RCTViewManager
@end

@implementation RtnDevConsoleViewManager

RCT_EXPORT_MODULE(RtnDevConsoleView)

 - (UIView *)view
 {
   return [[UIView alloc] init];
 }

#pragma mark - Exported View Properties

// RCT_CUSTOM_VIEW_PROPERTY(color, NSString, UIView)
// {
//   [view setBackgroundColor: [Utils hexStringToColor:json]];
// }

RCT_EXPORT_VIEW_PROPERTY(initialText, NSString);

RCT_EXPORT_VIEW_PROPERTY(host, NSString);

RCT_EXPORT_VIEW_PROPERTY(port, UInt16);

RCT_EXPORT_VIEW_PROPERTY(username, NSString);

RCT_EXPORT_VIEW_PROPERTY(password, NSString);

RCT_EXPORT_VIEW_PROPERTY(fontColor, NSString);

RCT_EXPORT_VIEW_PROPERTY(fontSize, CGFloat);

RCT_EXPORT_VIEW_PROPERTY(fontFamily, NSString);

RCT_EXPORT_VIEW_PROPERTY(backgroundColor, NSString);

RCT_EXPORT_VIEW_PROPERTY(cursorColor, NSString);

RCT_EXPORT_VIEW_PROPERTY(scrollbackLines, NSInteger);

RCT_EXPORT_VIEW_PROPERTY(onDataReceived, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onSizeChanged, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(inputEnabled, BOOL);

@end
