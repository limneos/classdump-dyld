@class SBLockScreenViewController;

@interface SBLockScreenManager : NSObject

+ (instancetype)sharedInstance;

- (void)lockUIFromSource:(NSUInteger)source withOptions:(id)options;

@property (nonatomic, retain) SBLockScreenViewController *lockScreenViewController;

@property BOOL isUILocked;

@end
