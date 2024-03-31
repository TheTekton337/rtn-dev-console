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

QUICK_RCT_EXPORT_COMMAND_METHOD(clearUpdateRange)
QUICK_RCT_EXPORT_COMMAND_METHOD(emitLineFeed)
QUICK_RCT_EXPORT_COMMAND_METHOD(garbageCollectPayload)
QUICK_RCT_EXPORT_COMMAND_METHOD(hideCursor)
QUICK_RCT_EXPORT_COMMAND_METHOD(showCursor)
QUICK_RCT_EXPORT_COMMAND_METHOD(resetToInitialState)
QUICK_RCT_EXPORT_COMMAND_METHOD(scroll)
QUICK_RCT_EXPORT_COMMAND_METHOD(softReset)
QUICK_RCT_EXPORT_COMMAND_METHOD(updateFullScreen)

// TODO: Consider supporting QUICK_RCT_EXPORT_COMMAND_METHOD_PARAMS instead
RCT_EXPORT_METHOD(sendMotionWithButtonFlags:(nonnull NSNumber *)reactTag
                  buttonFlags:(NSInteger)buttonFlags
                  x:(NSInteger)x
                  y:(NSInteger)y
                  pixelX:(NSInteger)pixelX
                  pixelY:(NSInteger)pixelY)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view sendMotionWithButtonFlags:buttonFlags x:x y:y pixelX:pixelX pixelY:pixelY];
        }
    }];
}

RCT_EXPORT_METHOD(encodeButtonWithButton:(nonnull NSNumber *)reactTag
                  button:(NSInteger)button
                  release:(BOOL)release
                  shift:(BOOL)shift
                  meta:(BOOL)meta
                  control:(BOOL)control
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            NSInteger result = [view encodeButtonWithButton:button release:release shift:shift meta:meta control:control];
            resolve(@(result));
        } else {
            reject(@"no_view", @"Couldn't find view", nil);
        }
    }];
}

RCT_EXPORT_METHOD(sendEventWithButtonFlags:(nonnull NSNumber *)reactTag
                   buttonFlags:(NSInteger)buttonFlags
                   x:(NSInteger)x
                   y:(NSInteger)y)
 {
     [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
         RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
         if ([view isKindOfClass:[RtnSshTerminalView class]]) {
             [view sendEventWithButtonFlags:buttonFlags x:x y:y];
         }
     }];
 }

RCT_EXPORT_METHOD(sendEventWithButtonFlagsPixel:(nonnull NSNumber *)reactTag
                  buttonFlags:(NSInteger)buttonFlags
                  x:(NSInteger)x
                  y:(NSInteger)y
                  pixelX:(NSInteger)pixelX
                  pixelY:(NSInteger)pixelY)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view sendEventWithButtonFlags:buttonFlags x:x y:y pixelX:pixelX pixelY:pixelY];
        }
    }];
}

//RCT_EXPORT_METHOD(feedBuffer:(nonnull NSNumber *)reactTag
//                  text:(NSString *)text)
//{
//    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
//        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
//        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
//            [view feedBuffer:text];
//        }
//    }];
//}

RCT_EXPORT_METHOD(feedText:(nonnull NSNumber *)reactTag
                  text:(NSString *)text)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view feedText:text];
        }
    }];
}

//RCT_EXPORT_METHOD(feedByteArray:(nonnull NSNumber *)reactTag
//                  text:(NSString *)text)
//{
//    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
//        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
//        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
//            [view feedByteArray:text];
//        }
//    }];
//}

RCT_EXPORT_METHOD(sendResponse:(nonnull NSNumber *)reactTag
                  items:(NSString *)items)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            NSData *data = [[NSData alloc] initWithBase64EncodedString:items options:0];
            [view sendResponse:data];
        }
    }];
}

RCT_EXPORT_METHOD(sendResponseText:(nonnull NSNumber *)reactTag
                  text:(NSString *)text)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view sendResponseText:text];
        }
    }];
}

// Assuming changedLines returns a set of NSNumbers, will need to handle asynchronously
RCT_EXPORT_METHOD(changedLines:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            NSSet<NSNumber *> *lines = [view changedLines];
            resolve([lines allObjects]); // Convert to array since NSSet cannot be directly sent
        } else {
            reject(@"no_view", @"Couldn't find RtnSshTerminalView", nil);
        }
    }];
}

RCT_EXPORT_METHOD(getBufferAsString:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            NSString *bufferAsString = [view getBufferAsString];
            resolve(bufferAsString);
        } else {
            reject(@"no_view", @"Couldn't find RtnSshTerminalView", nil);
        }
    }];
}

RCT_EXPORT_METHOD(getTopVisibleRow:(nonnull NSNumber *)reactTag
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            NSInteger topVisibleRow = [view getTopVisibleRow];
            resolve(@(topVisibleRow));
        } else {
            reject(@"no_view", @"Couldn't find RtnSshTerminalView", nil);
        }
    }];
}

RCT_EXPORT_METHOD(installColors:(nonnull NSNumber *)reactTag
                  colors:(NSString *)colors)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view installColors:colors];
        }
    }];
}

RCT_EXPORT_METHOD(refresh:(nonnull NSNumber *)reactTag
                  startRow:(NSInteger)startRow
                  endRow:(NSInteger)endRow)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view refresh:startRow endRow:endRow];
        }
    }];
}

RCT_EXPORT_METHOD(resize:(nonnull NSNumber *)reactTag
                  cols:(NSInteger)cols
                  rows:(NSInteger)rows)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view resize:cols rows:rows];
        }
    }];
}

RCT_EXPORT_METHOD(setIconTitle:(nonnull NSNumber *)reactTag
                  text:(NSString *)text)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view setIconTitle:text];
        }
    }];
}

RCT_EXPORT_METHOD(setTitle:(nonnull NSNumber *)reactTag
                  text:(NSString *)text)
{
    [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        RtnSshTerminalView *view = (RtnSshTerminalView *)viewRegistry[reactTag];
        if ([view isKindOfClass:[RtnSshTerminalView class]]) {
            [view setTitle:text];
        }
    }];
}

@end
