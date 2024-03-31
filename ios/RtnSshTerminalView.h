// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#import <React/RCTComponent.h>

#import <SwiftTerm/SwiftTerm-Swift.h>
#import <SwiftSH/SwiftSH-Swift.h>
#import <rtn_dev_console/rtn_dev_console-Swift.h>

#ifndef RtnSshTerminalViewNativeComponent_h
#define RtnSshTerminalViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface RtnSshTerminalView : RCTViewComponentView<SshTerminalViewDelegate>

@property (nonatomic, copy) RCTBubblingEventBlock onSizeChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onHostCurrentDirectoryUpdate;
@property (nonatomic, copy) RCTBubblingEventBlock onScrolled;
@property (nonatomic, copy) RCTBubblingEventBlock onRequestOpenLink;
@property (nonatomic, copy) RCTBubblingEventBlock onBell;
@property (nonatomic, copy) RCTBubblingEventBlock onClipboardCopy;
@property (nonatomic, copy) RCTBubblingEventBlock onITermContent;
@property (nonatomic, copy) RCTBubblingEventBlock onRangeChanged;
@property (nonatomic, copy) RCTBubblingEventBlock onConnected;
@property (nonatomic, copy) RCTBubblingEventBlock onClosed;
@property (nonatomic, copy) RCTBubblingEventBlock onSshError;
@property (nonatomic, copy) RCTBubblingEventBlock onSshConnectionError;

- (void)sendMotionWithButtonFlags:(NSInteger)buttonFlags
                                x:(NSInteger)x
                                y:(NSInteger)y
                           pixelX:(NSInteger)pixelX
                           pixelY:(NSInteger)pixelY;
- (NSInteger)encodeButtonWithButton:(NSInteger)button release:(BOOL)release shift:(BOOL)shift meta:(BOOL)meta control:(BOOL)control;
- (void)sendEventWithButtonFlags:(NSInteger)buttonFlags x:(NSInteger)x y:(NSInteger)y;
- (void)sendEventWithButtonFlags:(NSInteger)buttonFlags x:(NSInteger)x y:(NSInteger)y pixelX:(NSInteger)pixelX pixelY:(NSInteger)pixelY;
// - (void)feedBuffer:(NSData *)buffer;
- (void)feedText:(NSString *)text;
// - (void)feedByteArray:(NSData *)byteArray;
//- (void)getText;
- (void)sendResponse:(NSData *)items;
- (void)sendResponseText:(NSString *)text;
- (NSSet<NSNumber *> *)changedLines;
- (void)clearUpdateRange;
- (void)emitLineFeed;
- (void)garbageCollectPayload;
- (NSString *)getBufferAsString;
//- (void)getCharData;
//- (void)getCharacter;
//- (void)getCursorLocation;
//- (void)getDims;
//- (void)getLine;
//- (void)getScrollInvariantLine;
//- (void)getScrollInvariantUpdateRange;
- (NSInteger)getTopVisibleRow;
//- (void)getUpdateRange;
- (void)hideCursor;
- (void)showCursor;
- (void)installColors:(NSString *)colors;
- (void)refresh:(NSInteger)startRow endRow:(NSInteger)endRow;
//- (void)registerOscHandler;
- (void)resetToInitialState;
- (void)resize:(NSInteger)cols rows:(NSInteger)rows;
- (void)scroll;
//- (void)setCursorStyle;
- (void)setIconTitle:(NSString *)text;
- (void)setTitle:(NSString *)text;
- (void)softReset;
- (void)updateFullScreen;

@end

NS_ASSUME_NONNULL_END

#endif /* RtnSshTerminalViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
