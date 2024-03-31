#ifdef RCT_NEW_ARCH_ENABLED
#import "RtnSshTerminalView.h"

#import <react/renderer/components/RNRtnSshTerminalViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNRtnSshTerminalViewSpec/EventEmitters.h>
#import <react/renderer/components/RNRtnSshTerminalViewSpec/Props.h>
#import <react/renderer/components/RNRtnSshTerminalViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "Utils.h"

#import <SwiftTerm/SwiftTerm-Swift.h>
#import <SwiftSH/SwiftSH-Swift.h>
#import <rtn_dev_console/rtn_dev_console-Swift.h>

using namespace facebook::react;

@interface RtnSshTerminalView () <RCTRtnSshTerminalViewViewProtocol>

@end

@implementation RtnSshTerminalView {
    SshTerminalViewController *_sshTerminalViewController;

    Boolean _connected;
    
    Boolean _debug;
    Boolean _inputEnabled;

    NSString * _initialText;

    NSString * _host;
    NSInteger _port;
    NSString * _username;
    NSString * _password;

    NSString * _fontColor;
    NSInteger _fontSize;
    NSString * _fontFamily;
    NSString * _backgroundColor;
    NSString * _cursorColor;
    NSInteger _scrollbackLines;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RtnSshTerminalViewComponentDescriptor>();
}

// TODO: Review cleanup.
//#if !TARGET_OS_OSX
//// Reproduce the idea from here: https://github.com/facebook/react-native/blob/8bd3edec88148d0ab1f225d2119435681fbbba33/React/Fabric/Mounting/ComponentViews/InputAccessory/RCTInputAccessoryComponentView.mm#L142
//- (void)prepareForRecycle {
//    [super prepareForRecycle];
//    [_view destroyWebView];
//}
//#endif // !TARGET_OS_OSX

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RtnSshTerminalViewProps>();
    _props = defaultProps;

    const auto &newViewProps = *std::static_pointer_cast<RtnSshTerminalViewProps const>(_props);

    _connected = NO;

    _debug = NO;
    _inputEnabled = YES;

    _initialText = [[NSString alloc] initWithUTF8String: newViewProps.initialText.c_str()];

    _host = [[NSString alloc] initWithUTF8String: newViewProps.host.c_str()];
    _port = (NSInteger)newViewProps.port;
    _username = [[NSString alloc] initWithUTF8String: newViewProps.username.c_str()];
    _password = [[NSString alloc] initWithUTF8String: newViewProps.password.c_str()];

    // _fontColor = [[NSString alloc] initWithUTF8String: newViewProps.fontColor.c_str()];
    // _fontSize = (NSInteger)newViewProps.fontSize;
    // _fontFamily = [[NSString alloc] initWithUTF8String: newViewProps.fontFamily.c_str()];
    // _backgroundColor = [[NSString alloc] initWithUTF8String: newViewProps.backgroundColor.c_str()];;
    // _cursorColor = [[NSString alloc] initWithUTF8String: newViewProps.cursorColor.c_str()];;
    // _scrollbackLines = (NSInteger)newViewProps.scrollbackLines;
    
    _sshTerminalViewController = [SshTerminalViewController new];
      
    SshTerminalView * sshTerminalView =_sshTerminalViewController.view.subviews.firstObject;
    sshTerminalView.sshTerminalViewDelegate = self;

    self.contentView = _sshTerminalViewController.view;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<RtnSshTerminalViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RtnSshTerminalViewProps const>(props);

    if (oldViewProps.debug!= newViewProps.debug) {
        _inputEnabled = newViewProps.inputEnabled;
    }

    if (oldViewProps.debug!= newViewProps.debug) {
        _debug = newViewProps.debug;
    }

    if (oldViewProps.host != newViewProps.host) {
        _host = [[NSString alloc] initWithUTF8String: newViewProps.host.c_str()];
        // NSString * colorToConvert = [[NSString alloc] initWithUTF8String: newViewProps.color.c_str()];
        // [_view setBackgroundColor: [Utils hexStringToColor:colorToConvert]];
    }
    
    if (oldViewProps.port != newViewProps.port) {
        _port = (NSInteger)newViewProps.port;
    }
    
    if (oldViewProps.username != newViewProps.username) {
        _username = [[NSString alloc] initWithUTF8String: newViewProps.username.c_str()];
    }
    
    if (oldViewProps.password != newViewProps.password) {
        _password = [[NSString alloc] initWithUTF8String: newViewProps.password.c_str()];
    }
    
    if (oldViewProps.initialText != newViewProps.initialText) {
        _initialText = [[NSString alloc] initWithUTF8String: newViewProps.initialText.c_str()];
    }
    
//    TODO: Add _connecting bool or change to _connectionState?
    if (!_connected && ![_host  isEqual: @""] && _port > 0 && ![_password  isEqual: @""]) {
        _connected = YES;
        [_sshTerminalViewController initSSHConnectionWithHost:_host port:_port username:_username password:_password inputEnabled:_inputEnabled initialText:_initialText debug:_debug];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(nonnull const NSString *)commandName args:(nonnull const NSArray *)args {
    RCTRtnSshTerminalViewHandleCommand(self, commandName, args);
}

Class<RCTComponentViewProtocol> RtnSshTerminalViewCls(void)
{
    return RtnSshTerminalView.class;
}

- (void)onSizeChangedWithSource:(TerminalView * _Nonnull)source newCols:(NSInteger)newCols newRows:(NSInteger)newRows {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnSizeChanged data = {
        .terminalId = static_cast<int>(source.tag),
        .newCols = static_cast<int>(newCols),
        .newRows = static_cast<int>(newRows),
    };
    
    rtnSshTerminalEventEmitter->onSizeChanged(data);
}

- (void)onHostCurrentDirectoryUpdateWithSource:(TerminalView * _Nonnull)source directory:(NSString * _Nullable)directory {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnHostCurrentDirectoryUpdate data = {
        .terminalId = static_cast<int>(source.tag),
        .directory = directory ? std::string([directory UTF8String]) : std::string(),
    };
    
    rtnSshTerminalEventEmitter->onHostCurrentDirectoryUpdate(data);
}

- (void)onScrolledWithSource:(TerminalView * _Nonnull)source position:(double)position {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnScrolled data = {
        .terminalId = static_cast<int>(source.tag),
        .position = static_cast<double>(position),
    };
    
    rtnSshTerminalEventEmitter->onScrolled(data);
}

- (void)onRequestOpenLinkWithSource:(TerminalView * _Nonnull)source link:(NSString * _Nonnull)link params:(NSDictionary<NSString *,NSString *> * _Nonnull)params {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    
    if (!jsonData) {
        //        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *paramsJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnRequestOpenLink data = {
        .terminalId = static_cast<int>(source.tag),
        .link = std::string([link UTF8String]),
        .params = std::string([paramsJson UTF8String]),
    };
    
    rtnSshTerminalEventEmitter->onRequestOpenLink(data);
}

- (void)onBellWithSource:(TerminalView * _Nonnull)source {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnBell data = {
        .terminalId = static_cast<int>(source.tag),
    };
    
    rtnSshTerminalEventEmitter->onBell(data);
}

- (void)onClipboardCopyWithSource:(TerminalView * _Nonnull)source content:(NSString * _Nonnull)content {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnClipboardCopy data = {
        .terminalId = static_cast<int>(source.tag),
        .content = std::string([content UTF8String]),
    };
    
    rtnSshTerminalEventEmitter->onClipboardCopy(data);
}

- (void)onITermContentWithSource:(TerminalView * _Nonnull)source content:(NSData * _Nonnull)content {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:0 error:&error];
    
    if (!jsonData) {
        //        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *paramsJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnITermContent data = {
        .terminalId = static_cast<int>(source.tag),
        .content = std::string([paramsJson UTF8String]),
    };
    
    rtnSshTerminalEventEmitter->onITermContent(data);
}

- (void)onRangeChangedWithSource:(TerminalView * _Nonnull)source startY:(NSInteger)startY endY:(NSInteger)endY {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnRangeChanged data = {
        .terminalId = static_cast<int>(source.tag),
        .startY = static_cast<int>(startY),
        .endY = static_cast<int>(endY),
    };
    
    rtnSshTerminalEventEmitter->onRangeChanged(data);
}

- (void)onLoadWithSource:(TerminalView * _Nonnull)source {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLoad data = {
        .terminalId = static_cast<int>(source.tag)
    };
    
    rtnSshTerminalEventEmitter->onTerminalLoad(data);
}

- (void)onConnectWithSource:(TerminalView * _Nonnull)source {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnConnect data = {
        .terminalId = static_cast<int>(source.tag)
    };
    
    rtnSshTerminalEventEmitter->onConnect(data);
}

- (void)onClosedWithSource:(TerminalView * _Nonnull)source reason:(NSString * _Nonnull)reason {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnClosed data = {
        .terminalId = static_cast<int>(source.tag),
        .reason = std::string([reason UTF8String])
    };
    
    rtnSshTerminalEventEmitter->onClosed(data);
}

- (void)onSshErrorWithSource:(TerminalView * _Nullable)source error:(NSData * _Nonnull)error {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:error options:0 error:&jsonError];
    
    if (!jsonData) {
        //        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *errorJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnSshError data = {
        .terminalId = static_cast<int>(source.tag),
        .error = std::string([errorJson UTF8String]),
    };
    
    rtnSshTerminalEventEmitter->onSshError(data);
}

- (void)onSshConnectionErrorWithSource:(TerminalView * _Nonnull)source error:(NSError * _Nonnull)error { 
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:error.userInfo options:0 error:&jsonError];
    
    if (!jsonData) {
        //        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *errorJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnSshConnectionError data = {
        .terminalId = static_cast<int>(source.tag),
        .error = std::string([errorJson UTF8String]),
    };
    
    rtnSshTerminalEventEmitter->onSshConnectionError(data);
}

- (void)sendMotionWithButtonFlags:(NSInteger)buttonFlags
                                x:(NSInteger)x
                                y:(NSInteger)y
                           pixelX:(NSInteger)pixelX
                           pixelY:(NSInteger)pixelY {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController sendMotionWithButtonFlags:buttonFlags x:x y:y pixelX:pixelX pixelY:pixelY];
    }
}

- (NSInteger)encodeButtonWithButton:(NSInteger)button release:(BOOL)release shift:(BOOL)shift meta:(BOOL)meta control:(BOOL)control {
    if (_sshTerminalViewController != nil) {
        return [_sshTerminalViewController encodeButtonWithButton:button release:release shift:shift meta:meta control:control];
    } else {
        return 0;
    }
}

- (void)sendEventWithButtonFlags:(NSInteger)buttonFlags x:(NSInteger)x y:(NSInteger)y {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController sendEventWithButtonFlags:buttonFlags x:x y:y];
    }
}

- (void)sendEventWithButtonFlags:(NSInteger)buttonFlags x:(NSInteger)x y:(NSInteger)y pixelX:(NSInteger)pixelX pixelY:(NSInteger)pixelY {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController sendEventWithButtonFlags:buttonFlags x:x y:y pixelX:pixelX pixelY:pixelY];
    }
}

- (void)feedBuffer:(NSData *)buffer {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController feedWithBuffer:buffer];
    }
}

- (void)feedText:(NSString *)text {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController feedWithText:text];
    }
}

- (void)feedByteArray:(NSData *)byteArray {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController feedWithByteArray:byteArray];
    }
}

//- (void)getText:(NSString *)text {
//    if (_sshTerminalViewController != nil) {
//        return [_sshTerminalViewController getText];
//    }
//}

- (void)sendResponse:(NSData *)items {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController sendResponseWithItems:items];
    }
}

- (void)sendResponseText:(NSString *)text {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController sendResponseWithText:text];
    }
}

- (NSSet<NSNumber *> *)changedLines {
    if (_sshTerminalViewController != nil) {
        return [_sshTerminalViewController changedLines];
    } else {
        return nil;
    }
}

- (void)clearUpdateRange {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController clearUpdateRange];
    }
}

- (void)emitLineFeed {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController emitLineFeed];
    }
}

- (void)garbageCollectPayload {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController garbageCollectPayload];
    }
}

- (NSString *)getBufferAsString {
    if (_sshTerminalViewController != nil) {
        return [_sshTerminalViewController getBufferAsString];
    } else {
        return nil;
    }
}

//- (void)getCharData {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getCharData];
//    }
//}

//- (void)getCharacter {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getCharacter];
//    }
//}

//- (void)getCursorLocation {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getCursorLocation];
//    }
//}

//- (void)getDims {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getDims];
//    }
//}

//- (void)getLine {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getLine];
//    }
//}

//- (void)getScrollInvariantLine {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getScrollInvariantLine];
//    }
//}

//- (void)getScrollInvariantUpdateRange {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getScrollInvariantUpdateRange];
//    }
//}

- (NSInteger)getTopVisibleRow {
    if (_sshTerminalViewController != nil) {
        return [_sshTerminalViewController getTopVisibleRow];
    } else {
//        TODO: abort() is called when less than 0 in getTopVisibleRow
//              Does the RN component need to protect users from this?
        return -1;
    }
}

//- (void)getUpdateRange {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController getUpdateRange];
//    }
//}

- (void)hideCursor {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController hideCursor];
    }
}

- (void)showCursor {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController showCursor];
    }
}

- (void)installColors:(NSString *)colors {
    if (_sshTerminalViewController == nil) {
        return;
    }
    
    NSError *error = nil;
    
    NSData *jsonData = [colors dataUsingEncoding:NSUTF8StringEncoding];
    NSArray<NSString *> *colorsArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if (error != nil) {
        NSLog(@"installColors error: failed parsing JSON for colors: %@", error);
        return;
    }
    
    if (![colorsArray isKindOfClass:[NSArray class]]) {
        NSLog(@"installColors error: deserialized object is not an NSArray.");
        return;
    }

    BOOL allElementsAreStrings = YES;
    for (id element in colorsArray) {
        if (![element isKindOfClass:[NSString class]]) {
            allElementsAreStrings = NO;
            break;
        }
    }
    
    if (!allElementsAreStrings) {
        NSLog(@"installColors error: not all elements in the colors array are strings.");
        return;
    }
    
    [_sshTerminalViewController installColorsWithColors:colorsArray];
}

- (void)refresh:(NSInteger)startRow endRow:(NSInteger)endRow {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController refreshWithStartRow:startRow endRow:endRow];
    }
}

- (void)resetToInitialState {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController resetToInitialState];
    }
}

- (void)resize:(NSInteger)cols rows:(NSInteger)rows {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController resizeWithCols:cols rows:rows];
    }
}

- (void)scroll {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController scroll];
    }
}

//- (void)setCursorStyle {
//    if (_sshTerminalViewController != nil) {
//        [_sshTerminalViewController setCursorStyle];
//    }
//}

- (void)setIconTitle:(NSString *)text {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController setIconTitleWithText:text];
    }
}

- (void)setTitle:(NSString *)text {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController setTitle:text];
    }
}

- (void)softReset {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController softReset];
    }
}

- (void)updateFullScreen {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController updateFullScreen];
    }
}

@end
#endif
