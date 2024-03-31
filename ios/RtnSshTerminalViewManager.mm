#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import <React/RCTBridge.h>
// #import "Utils.h"
#import "RtnSshTerminalView.h"

@interface RtnSshTerminalViewManager : RCTViewManager
@end

@implementation RtnSshTerminalViewManager

RCT_EXPORT_MODULE(RtnSshTerminalView)

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

RCT_EXPORT_VIEW_PROPERTY(inputEnabled, BOOL);

RCT_EXPORT_VIEW_PROPERTY(debug, BOOL);

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

RCT_EXPORT_VIEW_PROPERTY(onConnectionChanged, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onSizeChanged, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onHostCurrentDirectoryUpdate, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onScrolled, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onRequestOpenLink, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onBell, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onClipboardCopy, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onITermContent, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onRangeChanged, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onTerminalLoad, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onConnect, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onClosed, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onSshError, RCTBubblingEventBlock);

RCT_EXPORT_VIEW_PROPERTY(onSshConnectionError, RCTBubblingEventBlock);

// BASE_VIEW_PER_OS(), QUICK_RCT_EXPORT_COMMAND_METHOD(), and QUICK_RCT_EXPORT_COMMAND_METHOD_PARAMS example from react-native-webview
// See: https://github.com/react-native-webview/react-native-webview/blob/b989bd679a447c34435538588b27c86b3045ae53/apple/RNCWebViewManager.mm
#if !TARGET_OS_OSX
    #define BASE_VIEW_PER_OS() UIView
#else
    #define BASE_VIEW_PER_OS() NSView
#endif

#define QUICK_RCT_EXPORT_COMMAND_METHOD(name)                                                                                           \
RCT_EXPORT_METHOD(name:(nonnull NSNumber *)reactTag)                                                                                    \
{                                                                                                                                       \
[self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, BASE_VIEW_PER_OS() *> *viewRegistry) {   \
RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];                                                                    \
    if (![view isKindOfClass:[RtnSshTerminalView class]]) {                                                                                 \
      RCTLogError(@"Invalid view returned from registry, expecting RtnSshTerminalView, got: %@", view);                                         \
    } else {                                                                                                                            \
      [view name];                                                                                                                      \
    }                                                                                                                                   \
  }];                                                                                                                                   \
}
#define QUICK_RCT_EXPORT_COMMAND_METHOD_PARAMS(name, in_param, out_param)                                                               \
RCT_EXPORT_METHOD(name:(nonnull NSNumber *)reactTag in_param)                                                                           \
{                                                                                                                                       \
[self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, BASE_VIEW_PER_OS() *> *viewRegistry) {   \
RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];                                                                    \
    if (![view isKindOfClass:[RtnSshTerminalView class]]) {                                                                                 \
      RCTLogError(@"Invalid view returned from registry, expecting RtnSshTerminalView, got: %@", view);                                         \
    } else {                                                                                                                            \
      [view name:out_param];                                                                                                            \
    }                                                                                                                                   \
  }];                                                                                                                                   \
}

QUICK_RCT_EXPORT_COMMAND_METHOD(hideCursor)
QUICK_RCT_EXPORT_COMMAND_METHOD(showCursor)

@end
