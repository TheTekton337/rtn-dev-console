#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import "RCTBridge.h"

@interface RtnDevConsoleViewManager : RCTViewManager
@end

@implementation RtnDevConsoleViewManager

RCT_EXPORT_MODULE(RtnDevConsoleView)

- (UIView *)view
{
  return [[UIView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(color, NSString)

@end
