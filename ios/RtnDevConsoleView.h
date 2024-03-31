// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#import <React/RCTComponent.h>

#import <SwiftTerm/SwiftTerm-Swift.h>
#import <SwiftSH/SwiftSH-Swift.h>
#import <rtn_dev_console/rtn_dev_console-Swift.h>

#ifndef RtnDevConsoleViewNativeComponent_h
#define RtnDevConsoleViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface RtnDevConsoleView : RCTViewComponentView<SshTerminalViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onSizeChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onHostCurrentDirectoryUpdate;
@property (nonatomic, copy) RCTBubblingEventBlock onScrolled;
@property (nonatomic, copy) RCTBubblingEventBlock onRequestOpenLink;
@property (nonatomic, copy) RCTBubblingEventBlock onBell;
@property (nonatomic, copy) RCTBubblingEventBlock onClipboardCopy;
@property (nonatomic, copy) RCTBubblingEventBlock onITermContent;
@property (nonatomic, copy) RCTBubblingEventBlock onRangeChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onTerminalLoad;
@property (nonatomic, copy) RCTBubblingEventBlock onConnected;
@property (nonatomic, copy) RCTBubblingEventBlock onClosed;
@property (nonatomic, copy) RCTBubblingEventBlock onSshError;
@property (nonatomic, copy) RCTBubblingEventBlock onSshConnectionError;

- (void)hideCursor;
- (void)showCursor;

@end

NS_ASSUME_NONNULL_END

#endif /* RtnDevConsoleViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
