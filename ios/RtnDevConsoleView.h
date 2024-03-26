// This guard prevent this file to be compiled in the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

#ifndef RtnDevConsoleViewNativeComponent_h
#define RtnDevConsoleViewNativeComponent_h

NS_ASSUME_NONNULL_BEGIN

@interface RtnDevConsoleView : RCTViewComponentView
@end

NS_ASSUME_NONNULL_END

#endif /* RtnDevConsoleViewNativeComponent_h */
#endif /* RCT_NEW_ARCH_ENABLED */
