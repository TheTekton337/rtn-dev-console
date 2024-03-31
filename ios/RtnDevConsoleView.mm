#ifdef RCT_NEW_ARCH_ENABLED
#import "RtnDevConsoleView.h"

#import <react/renderer/components/RNRtnDevConsoleViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNRtnDevConsoleViewSpec/EventEmitters.h>
#import <react/renderer/components/RNRtnDevConsoleViewSpec/Props.h>
#import <react/renderer/components/RNRtnDevConsoleViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import "Utils.h"

#import <SwiftTerm/SwiftTerm-Swift.h>
#import <SwiftSH/SwiftSH-Swift.h>
#import <rtn_dev_console/rtn_dev_console-Swift.h>

using namespace facebook::react;

@interface RtnDevConsoleView () <RCTRtnDevConsoleViewViewProtocol>

@end

@implementation RtnDevConsoleView {
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
    return concreteComponentDescriptorProvider<RtnDevConsoleViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RtnDevConsoleViewProps>();
    _props = defaultProps;

    const auto &newViewProps = *std::static_pointer_cast<RtnDevConsoleViewProps const>(_props);

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
    const auto &oldViewProps = *std::static_pointer_cast<RtnDevConsoleViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RtnDevConsoleViewProps const>(props);

    if (oldViewProps.debug!= newViewProps.debug) {
        _inputEnabled = newViewProps.inputEnabled;
    }

    if (oldViewProps.debug!= newViewProps.debug) {
        _debug = newViewProps.debug;
    }

    if (oldViewProps.initialText != newViewProps.initialText) {
        _initialText = [[NSString alloc] initWithUTF8String: newViewProps.initialText.c_str()];
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
    
//    TODO: Add _connecting bool or change to _connectionState?
    if (!_connected && ![_host  isEqual: @""] && _port > 0 && ![_password  isEqual: @""]) {
        _connected = YES;
        [_sshTerminalViewController initSSHConnectionWithHost:_host port:_port username:_username password:_password inputEnabled:_inputEnabled initialText:_initialText debug:_debug];
    }

    [super updateProps:props oldProps:oldProps];
}

- (void)handleCommand:(nonnull const NSString *)commandName args:(nonnull const NSArray *)args {
    RCTRtnDevConsoleViewHandleCommand(self, commandName, args);
}

Class<RCTComponentViewProtocol> RtnDevConsoleViewCls(void)
{
    return RtnDevConsoleView.class;
}

- (void)onSizeChangedWithSource:(TerminalView * _Nonnull)source newCols:(NSInteger)newCols newRows:(NSInteger)newRows {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnSizeChanged data = {
        .terminalId = static_cast<int>(source.tag),
        .newCols = static_cast<int>(newCols),
        .newRows = static_cast<int>(newRows),
    };

    rtnDevConsoleEventEmitter->onSizeChanged(data);
}

- (void)onHostCurrentDirectoryUpdateWithSource:(TerminalView * _Nonnull)source directory:(NSString * _Nullable)directory {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnHostCurrentDirectoryUpdate data = {
        .terminalId = static_cast<int>(source.tag),
        .directory = directory ? std::string([directory UTF8String]) : std::string(),
    };

    rtnDevConsoleEventEmitter->onHostCurrentDirectoryUpdate(data);
}

- (void)onScrolledWithSource:(TerminalView * _Nonnull)source position:(double)position {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnScrolled data = {
        .terminalId = static_cast<int>(source.tag),
        .position = static_cast<double>(position),
    };

    rtnDevConsoleEventEmitter->onScrolled(data);
}

- (void)onRequestOpenLinkWithSource:(TerminalView * _Nonnull)source link:(NSString * _Nonnull)link params:(NSDictionary<NSString *,NSString *> * _Nonnull)params {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
        
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    
    if (!jsonData) {
//        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *paramsJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnRequestOpenLink data = {
        .terminalId = static_cast<int>(source.tag),
        .link = std::string([link UTF8String]),
        .params = std::string([paramsJson UTF8String]),
    };

    rtnDevConsoleEventEmitter->onRequestOpenLink(data);
}

- (void)onBellWithSource:(TerminalView * _Nonnull)source {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnBell data = {
        .terminalId = static_cast<int>(source.tag),
    };
    
    rtnDevConsoleEventEmitter->onBell(data);
}

- (void)onClipboardCopyWithSource:(TerminalView * _Nonnull)source content:(NSString * _Nonnull)content {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnClipboardCopy data = {
        .terminalId = static_cast<int>(source.tag),
        .content = std::string([content UTF8String]),
    };

    rtnDevConsoleEventEmitter->onClipboardCopy(data);
}

- (void)onITermContentWithSource:(TerminalView * _Nonnull)source content:(NSData * _Nonnull)content {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
        
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:0 error:&error];
    
    if (!jsonData) {
//        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *paramsJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnITermContent data = {
        .terminalId = static_cast<int>(source.tag),
        .content = std::string([paramsJson UTF8String]),
    };

    rtnDevConsoleEventEmitter->onITermContent(data);
}

- (void)onRangeChangedWithSource:(TerminalView * _Nonnull)source startY:(NSInteger)startY endY:(NSInteger)endY {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnRangeChanged data = {
        .terminalId = static_cast<int>(source.tag),
        .startY = static_cast<int>(startY),
        .endY = static_cast<int>(endY),
    };

    rtnDevConsoleEventEmitter->onRangeChanged(data);
}

- (void)onLoadWithSource:(TerminalView * _Nonnull)source {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnTerminalLoad data = {
        .terminalId = static_cast<int>(source.tag)
    };

    rtnDevConsoleEventEmitter->onTerminalLoad(data);
}

- (void)onConnectWithSource:(TerminalView * _Nonnull)source {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnConnect data = {
        .terminalId = static_cast<int>(source.tag)
    };

    rtnDevConsoleEventEmitter->onConnect(data);
}

- (void)onClosedWithSource:(TerminalView * _Nonnull)source reason:(NSString * _Nonnull)reason {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnClosed data = {
        .terminalId = static_cast<int>(source.tag),
        .reason = std::string([reason UTF8String])
    };

    rtnDevConsoleEventEmitter->onClosed(data);
}

- (void)onSshErrorWithSource:(TerminalView * _Nullable)source error:(NSData * _Nonnull)error {
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
        
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:error options:0 error:&jsonError];
    
    if (!jsonData) {
//        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *errorJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnSshError data = {
        .terminalId = static_cast<int>(source.tag),
        .error = std::string([errorJson UTF8String]),
    };

    rtnDevConsoleEventEmitter->onSshError(data);
}

- (void)onSshConnectionErrorWithSource:(TerminalView * _Nonnull)source error:(NSError * _Nonnull)error { 
    auto rtnDevConsoleEventEmitter = std::static_pointer_cast<RtnDevConsoleViewEventEmitter const>(_eventEmitter);
        
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:error.userInfo options:0 error:&jsonError];
    
    if (!jsonData) {
//        TODO: Emit RN Error event? Would this ever happen? Throw here?
        NSLog(@"Failed to serialize params to JSON: %@", error);
        return;
    }
    
    NSString *errorJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    facebook::react::RtnDevConsoleViewEventEmitter::OnSshConnectionError data = {
        .terminalId = static_cast<int>(source.tag),
        .error = std::string([errorJson UTF8String]),
    };

    rtnDevConsoleEventEmitter->onSshConnectionError(data);
}

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

@end
#endif
