@class SBWallpaperView;

@interface SBUIController : NSObject <UIGestureRecognizerDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, retain) SBWallpaperView *wallpaperView;

- (UIWindow *)window;

@end
