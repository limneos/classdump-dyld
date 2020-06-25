@class SBNotificationCenterViewController;

@interface SBNotificationCenterController : NSObject

+ (instancetype)sharedInstance;

- (void)presentAnimated:(BOOL)animated completion:(void(^)())completion;

@property (nonatomic, retain) SBNotificationCenterViewController *viewController;

@end
