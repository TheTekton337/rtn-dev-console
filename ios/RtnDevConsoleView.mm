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
// Test

using namespace facebook::react;

@interface RtnDevConsoleView () <RCTRtnDevConsoleViewViewProtocol>

@end

@implementation RtnDevConsoleView {
    SshTerminalView *_sshTerminalView;
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

    _fontColor = [[NSString alloc] initWithUTF8String: newViewProps.fontColor.c_str()];
    _fontSize = (NSInteger)newViewProps.fontSize;
    _fontFamily = [[NSString alloc] initWithUTF8String: newViewProps.fontFamily.c_str()];
    _backgroundColor = [[NSString alloc] initWithUTF8String: newViewProps.backgroundColor.c_str()];;
    _cursorColor = [[NSString alloc] initWithUTF8String: newViewProps.cursorColor.c_str()];;
    _scrollbackLines = (NSInteger)newViewProps.scrollbackLines;

    _sshTerminalView = [SshTerminalView new];

    self.contentView = _sshTerminalView;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<RtnDevConsoleViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<RtnDevConsoleViewProps const>(props);

    if (oldViewProps.color != newViewProps.color) {
        // TODO: Flesh out props.
        // NSString * colorToConvert = [[NSString alloc] initWithUTF8String: newViewProps.color.c_str()];
        // [_view setBackgroundColor: [Utils hexStringToColor:colorToConvert]];
    }

    [super updateProps:props oldProps:oldProps];
}

// TODO: Flesh out events.
- (void)handleDataReceived:(NSString *)data
{
    // if (self.onDataReceived) {
    //     self.onDataReceived(@{@"data": data});
    // }
}

- (void)handleSizeChangedWithCols:(NSInteger)cols rows:(NSInteger)rows
{
    // if (self.onSizeChanged) {
    //     self.onSizeChanged(@{@"cols": @(cols), @"rows": @(rows)});
    // }
}

Class<RCTComponentViewProtocol> RtnDevConsoleViewCls(void)
{
    return RtnDevConsoleView.class;
}

@end
#endif
