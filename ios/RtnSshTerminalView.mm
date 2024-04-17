#ifdef RCT_NEW_ARCH_ENABLED
#import "RtnSshTerminalView.h"

#import <react/renderer/components/RNRtnSshTerminalViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNRtnSshTerminalViewSpec/EventEmitters.h>
#import <react/renderer/components/RNRtnSshTerminalViewSpec/Props.h>
#import <react/renderer/components/RNRtnSshTerminalViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

#import <SwiftTerm/SwiftTerm-Swift.h>
#import <SwiftSH/SwiftSH-Swift.h>
#import <rtn_dev_console/Utils.h>
#import <rtn_dev_console/rtn_dev_console-Swift.h>

using namespace facebook::react;

@interface RtnSshTerminalView () <RCTRtnSshTerminalViewViewProtocol>

@end

@implementation RtnSshTerminalView {
    SshTerminalViewController *_sshTerminalViewController;

    Boolean _connected;
    
    Boolean _debug;
    Boolean _autoConnect;
    Boolean _canConnect;
    Boolean _inputEnabled;

    NSString * _initialText;

    NSString * _host;
    NSInteger _port;
    NSString * _terminal;
    NSMutableArray * _environmentVariables;
    
    AuthMethod _authMethod;
    
    NSMutableArray * _oscHandlerCodes;
    
    NSString * _username;
    NSString * _password;
    
    NSString * _publicKey;
    NSString * _privateKey;
    
    NSString * _publicKeyPath;
    NSString * _privateKeyPath;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<RtnSshTerminalViewComponentDescriptor>();
}

// TODO: Review cleanup.
//#if !TARGET_OS_OSX
//// Reproduce the idea from here: https://github.com/facebook/react-native/blob/8bd3edec88148d0ab1f225d2119435681fbbba33/React/Fabric/Mounting/ComponentViews/InputAccessory/RCTInputAccessoryComponentView.mm#L142
- (void)prepareForRecycle {
    [super prepareForRecycle];
    [_sshTerminalViewController destroySshTerminalView];
}
//#endif // !TARGET_OS_OSX

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const RtnSshTerminalViewProps>();
    _props = defaultProps;

    _autoConnect = YES;
    _canConnect = NO;
    _connected = NO;

    _debug = NO;
    _inputEnabled = YES;
    
    _environmentVariables = [[NSMutableArray alloc] init];
    _oscHandlerCodes = [[NSMutableArray alloc] init];
    
    _sshTerminalViewController = [SshTerminalViewController new];
      
    SshTerminalView * sshTerminalView = _sshTerminalViewController.view.subviews.firstObject;
    sshTerminalView.sshTerminalViewDelegate = self;

    self.contentView = _sshTerminalViewController.view;
  }

  return self;
}

- (NSString *)stringFromAuthType:(RtnSshTerminalViewAuthType)authType {
    switch (authType) {
        case RtnSshTerminalViewAuthType::Password:
            return @"password";
        case RtnSshTerminalViewAuthType::PubkeyFile:
            return @"pubkeyFile";
        case RtnSshTerminalViewAuthType::PubkeyMemory:
            return @"pubkeyMemory";
//        case RtnSshTerminalViewAuthType::Interactive:
//            return @"interactive";
        default:
            [NSException raise:@"InvalidAuthTypeException" format:@"Unknown RtnSshTerminalViewAuthType value"];
            return nil;
    }
}

- (AuthMethod)authMethodFromAuthType:(RtnSshTerminalViewAuthType)authType {
    switch (authType) {
        case RtnSshTerminalViewAuthType::Password:
            return AuthMethodPassword;
        case RtnSshTerminalViewAuthType::PubkeyFile:
            return AuthMethodPubkeyFile;
        case RtnSshTerminalViewAuthType::PubkeyMemory:
            return AuthMethodPubkeyMemory;
//        case RtnSshTerminalViewAuthType::Interactive:
//            return AuthMethodInteractive;
        default:
            [NSException raise:@"InvalidAuthTypeException" format:@"Unknown RtnSshTerminalViewAuthType value"];
            return AuthMethodPassword;
    }
}

- (NSArray<NSDictionary *> *)convertEnvironmentVariablesToNSArray:(const std::vector<facebook::react::RtnSshTerminalViewHostConfigEnvironmentStruct> *)environmentVariablesPtr {
    const auto& environmentVariables = *environmentVariablesPtr;
    NSMutableArray<NSDictionary *> *envArray = [[NSMutableArray alloc] init];
    
    for (const auto& envVar : environmentVariables) {
        NSString *name = [NSString stringWithUTF8String:envVar.name.c_str()];
        NSString *variable = [NSString stringWithUTF8String:envVar.variable.c_str()];
        [envArray addObject:@{@"name": name, @"variable": variable}];
    }
    
    return envArray;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<RtnSshTerminalViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RtnSshTerminalViewProps const>(props);

    if (oldViewProps.debug != newViewProps.debug) {
        _debug = newViewProps.debug;
    }
    
    if (oldViewProps.autoConnect != newViewProps.autoConnect) {
        _autoConnect = newViewProps.autoConnect;
        if (!newViewProps.autoConnect) {
//            TODO: Is the close callback needed here?
            [_sshTerminalViewController closeSSHConnection:nil];
        }
    }
    
    BOOL hostConfigChanged = NO;
    BOOL authConfigChanged = NO;
    BOOL environmentChanged = NO;
    
    if (oldViewProps.hostConfig.host != newViewProps.hostConfig.host) {
        _host = [[NSString alloc] initWithUTF8String: newViewProps.hostConfig.host.c_str()];
        hostConfigChanged = YES;
    }
    
    if (oldViewProps.hostConfig.port != newViewProps.hostConfig.port) {
        _port = (NSInteger)newViewProps.hostConfig.port;
        hostConfigChanged = YES;
    }
    
    if (oldViewProps.hostConfig.terminal != newViewProps.hostConfig.terminal) {
        _terminal = [[NSString alloc] initWithUTF8String: newViewProps.hostConfig.terminal.c_str()];
        hostConfigChanged = YES;
    }
    
    const auto& oldEnv = oldViewProps.hostConfig.environment;
    const auto& newEnv = newViewProps.hostConfig.environment;

    if (oldEnv.size() != newEnv.size()) {
        environmentChanged = YES;
    } else {
        for (size_t i = 0; i < newEnv.size(); i++) {
            const auto& oldVar = oldEnv[i];
            const auto& newVar = newEnv[i];
            if (oldVar.name != newVar.name || oldVar.variable != newVar.variable) {
                environmentChanged = YES;
                break;
            }
        }
    }
    
    if (environmentChanged) {
        NSArray<NSDictionary *> *newEnvironmentNSArray = [self convertEnvironmentVariablesToNSArray:&newViewProps.hostConfig.environment];

        _environmentVariables = [newEnvironmentNSArray mutableCopy];
        
        hostConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.authType != newViewProps.authConfig.authType) {
        _authMethod = [self authMethodFromAuthType:newViewProps.authConfig.authType];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.username != newViewProps.authConfig.username) {
        _username = [[NSString alloc] initWithUTF8String: newViewProps.authConfig.username.c_str()];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.password != newViewProps.authConfig.password) {
        _password = [[NSString alloc] initWithUTF8String: newViewProps.authConfig.password.c_str()];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.publicKey != newViewProps.authConfig.publicKey) {
        _publicKey = [[NSString alloc] initWithUTF8String: newViewProps.authConfig.publicKey.c_str()];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.privateKey != newViewProps.authConfig.privateKey) {
        _privateKey = [[NSString alloc] initWithUTF8String: newViewProps.authConfig.privateKey.c_str()];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.publicKeyPath != newViewProps.authConfig.publicKeyPath) {
        _publicKeyPath = [[NSString alloc] initWithUTF8String: newViewProps.authConfig.publicKeyPath.c_str()];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.authConfig.privateKeyPath != newViewProps.authConfig.privateKeyPath) {
        _privateKeyPath = [[NSString alloc] initWithUTF8String: newViewProps.authConfig.privateKeyPath.c_str()];
        authConfigChanged = YES;
    }
    
    if (oldViewProps.initialText != newViewProps.initialText) {
        _initialText = [[NSString alloc] initWithUTF8String: newViewProps.initialText.c_str()];
    }
    
    if (oldViewProps.oscHandlerCodes != newViewProps.oscHandlerCodes) {
        [self updateOscHandlers:newViewProps.oscHandlerCodes];
    }
    
//    TODO: Support inputEnabled prop
//    if (oldViewProps.inputEnabled != newViewProps.inputEnabled) {
//        _inputEnabled = newViewProps.inputEnabled;
//        
//        if (_inputEnabled) {
//            [_sshTerminalViewController enableInput];
//        } else {
//            [_sshTerminalViewController disableInput];
//        }
//    }
    
    _canConnect = [self tryToConnect:YES];
    
    if (_autoConnect && _canConnect && (authConfigChanged || hostConfigChanged)) {
        [self connect:YES];
    }

    [super updateProps:props oldProps:oldProps];
}

- (BOOL)tryToConnect:(BOOL)authConfigChanged {
    BOOL shouldConnect = NO;
    
    switch (_authMethod) {
        case AuthMethodPassword:
            shouldConnect = _host && _port && _terminal && _username && _password;
            break;
        case AuthMethodPubkeyFile:
            shouldConnect = _host && _port && _terminal && _username && _publicKeyPath && _privateKeyPath;
            break;
        case AuthMethodPubkeyMemory:
            shouldConnect = _host && _port && _terminal && _username && _publicKey && _privateKey;
            break;
        default:
            shouldConnect = NO;
    }

    return shouldConnect;
}

- (void)connect:(Boolean)forceConnect {
    if (_connected && !forceConnect) {
        NSLog(@"connect warning: SSH session already connected.");
        NSString *logType = [Utils nsStringFromLogType:LogTypeWarning];
        [self onTerminalLogWithSource:nil logType:logType message:@"SSH session already connected."];
        return;
    } else if (_connected && forceConnect) {
        NSLog(@"connect notice: SSH session forceConnect reconnecting.");
        [_sshTerminalViewController closeSSHConnection:^{
            [self connectWithConfig];
        }];
        return;
    }
    
    [self connectWithConfig];
}

- (void)connectWithConfig {
    NSLog(@"connectWithConfig");
    NSDictionary *config = [self getConfig];
    [_sshTerminalViewController initSSHConnectionWithConfig:config];
    _connected = YES;
}

- (NSDictionary *)getConfig {
    NSLog(@"getConfig");
    
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:@{
        @"method" : [Utils nsStringFromAuthMethod:_authMethod],
        @"host" : _host ?: @"",
        @"port" : @(_port),
        @"terminal": _terminal ?: @"",
        @"environment" : _environmentVariables ?: @[],
        @"inputEnabled" : @(_inputEnabled),
        @"debug" : @(_debug),
    }];

    if (_username) {
        config[@"username"] = _username;
    }

    if (_password) {
        config[@"password"] = _password;
    }

    switch (_authMethod) {
        case AuthMethodPassword:
            // Password already handled above
            break;
        case AuthMethodPubkeyFile:
            if (_publicKeyPath) {
                config[@"publicKeyPath"] = _publicKeyPath;
            }
            if (_privateKeyPath) {
                config[@"privateKeyPath"] = _privateKeyPath;
            }
            break;
        case AuthMethodPubkeyMemory:
            if (_publicKey) {
                config[@"publicKey"] = _publicKey;
            }
            if (_privateKey) {
                config[@"privateKey"] = _privateKey;
            }
//            Note: Quick way to save keys in dev
//            if (_publicKey && _privateKey) {
//                [self writeStringToFile:_publicKey fileName:@"publicKey.txt"];
//                [self writeStringToFile:_privateKey fileName:@"privateKey.txt"];
//            }
            break;
        default:
            break;
    }

    if (_initialText) {
        config[@"initialText"] = _initialText;
    }

    return [config copy];
}

- (void)updateOscHandlers:(std::vector<int>)newOscCodes {
    [self clearOscHandlers];
        
    for (int code : newOscCodes) {
        [_oscHandlerCodes addObject:@(code)];
    }
    
    [_sshTerminalViewController registerOscHandlersWithOscCodes:_oscHandlerCodes];
}

- (void)clearOscHandlers {
    [_oscHandlerCodes removeAllObjects];
}

- (void)handleCommand:(nonnull const NSString *)commandName args:(nonnull const NSArray *)args {
    RCTRtnSshTerminalViewHandleCommand(self, commandName, args);
}

- (void)writeStringToFile:(NSString *)string fileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSError *error;
    BOOL success = [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (success) {
        NSLog(@"File written to %@", filePath);
    } else {
        NSLog(@"Error writing file at %@: %@", filePath, error.localizedDescription);
    }
}

Class<RCTComponentViewProtocol> RtnSshTerminalViewCls(void)
{
    return RtnSshTerminalView.class;
}

- (void)onTerminalLogWithSource:(TerminalView * _Nullable)source logType:(NSString * _Nonnull)logTypeString message:(NSString * _Nonnull)message {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    LogType logType = [Utils logTypeFromNSString:logTypeString];
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLog data = {
        .terminalId = static_cast<int>(source.tag),
        .logType = ConvertLogTypeToCpp(logType),
        .message = std::string([message UTF8String])
    };
    
    rtnSshTerminalEventEmitter->onTerminalLog(data);
}

- (void)onOSCWithSource:(TerminalView * _Nonnull)source code:(NSInteger)code data:(NSString * _Nonnull)oscData {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnOSC data = {
        .terminalId = static_cast<int>(source.tag),
        .code = static_cast<int>(code),
        .data = std::string([oscData UTF8String]),
    };
    
    rtnSshTerminalEventEmitter->onOSC(data);
}

facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLogLogType ConvertLogTypeToCpp(LogType logType) {
    switch (logType) {
        case LogTypeWarning:
            return facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLogLogType::Warning;
        case LogTypeError:
            return facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLogLogType::Error;
        case LogTypeConnectionError:
            return facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLogLogType::ConnectionError;
        case LogTypeInfo:
        default:
            return facebook::react::RtnSshTerminalViewEventEmitter::OnTerminalLogLogType::Info;
    }
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

- (void)onDownloadCompleteWithSource:(TerminalView * _Nonnull)source callbackId:(NSString * _Nonnull)callbackId data:(NSString *)readData fileInfo:(NSString *)fileInfo error:(NSString *)error {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnDownloadComplete data = {
        .terminalId = static_cast<int>(source.tag),
        .callbackId = std::string([callbackId UTF8String])
    };
    
    if (readData != nil) {
        data.data = std::string([readData UTF8String]);
    }
    
    if (fileInfo != nil) {
        data.fileInfo = std::string([fileInfo UTF8String]);
    }
    
    if (error != nil) {
        data.error = std::string([error UTF8String]);
    }
    
    rtnSshTerminalEventEmitter->onDownloadComplete(data);
}

- (void)onUploadCompleteWithSource:(TerminalView * _Nonnull)source callbackId:(NSString * _Nonnull)callbackId bytesTransferred:(NSInteger)bytesTransferred error:(NSString *)error {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnUploadComplete data = {
        .terminalId = static_cast<int>(source.tag),
        .callbackId = std::string([callbackId UTF8String]),
        .bytesTransferred = static_cast<double>(bytesTransferred)
    };
    
    if (error != nil) {
        data.error = std::string([error UTF8String]);
    }
    
    rtnSshTerminalEventEmitter->onUploadComplete(data);
}

- (void)onDownloadProgressWithSource:(TerminalView * _Nonnull)source callbackId:(NSString * _Nonnull)callbackId bytesTransferred:(NSInteger)bytesTransferred {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnDownloadProgress data = {
        .terminalId = static_cast<int>(source.tag),
        .callbackId = std::string([callbackId UTF8String]),
        .bytesTransferred = static_cast<double>(bytesTransferred)
    };
    
    rtnSshTerminalEventEmitter->onDownloadProgress(data);
}

- (void)onUploadProgressWithSource:(TerminalView * _Nonnull)source callbackId:(NSString * _Nonnull)callbackId bytesTransferred:(NSInteger)bytesTransferred totalBytes:(NSInteger)totalBytes {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnUploadProgress data = {
        .terminalId = static_cast<int>(source.tag),
        .callbackId = std::string([callbackId UTF8String]),
        .bytesTransferred = static_cast<double>(bytesTransferred),
        .totalBytes = static_cast<double>(totalBytes)
    };
    
    rtnSshTerminalEventEmitter->onUploadProgress(data);
}

- (void)onCommandExecutedWithSource:(TerminalView * _Nonnull)source callbackId:(NSString * _Nonnull)callbackId data:(NSString *)readData error:(NSString*)error {
    auto rtnSshTerminalEventEmitter = std::static_pointer_cast<RtnSshTerminalViewEventEmitter const>(_eventEmitter);
    
    facebook::react::RtnSshTerminalViewEventEmitter::OnCommandExecuted data = {
        .terminalId = static_cast<int>(source.tag),
        .callbackId = std::string([callbackId UTF8String])
    };
    
    if (readData != nil) {
        data.data = std::string([readData UTF8String]);
    }
    
    if (error != nil) {
        data.error = std::string([error UTF8String]);
    }
    
    rtnSshTerminalEventEmitter->onCommandExecuted(data);
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

- (void)connect {
    _canConnect = [self tryToConnect:YES];
    
    if (_canConnect) {
        [self connect:YES];
    }
}

- (void)close {
    [_sshTerminalViewController closeSSHConnection:nil];
}

- (void)executeCommand:(NSString *)callbackId command:(NSString *)command {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController executeCommandWithCallbackId:callbackId command:command];
    }
}

- (void)writeCommand:(NSString *) command {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController writeCommandWithCommand:command];
    }
}

- (void)upload:(NSString *)callbackId from:(NSString *)from to:(NSString *)to {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController uploadWithCallbackId:callbackId from:from to:to];
    }
}

- (void)download:(NSString *)callbackId from:(NSString *)from to:(NSString *)to {
    if (_sshTerminalViewController != nil) {
        [_sshTerminalViewController downloadWithCallbackId:callbackId from:from to:to];
    }
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

- (void)sendEventWithButtonFlagsPixel:(NSInteger)buttonFlags x:(NSInteger)x y:(NSInteger)y pixelX:(NSInteger)pixelX pixelY:(NSInteger)pixelY {
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
