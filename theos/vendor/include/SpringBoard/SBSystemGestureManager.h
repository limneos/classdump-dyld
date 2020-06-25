typedef NS_ENUM(int64_t, SBSystemGestureType) {
	SBSystemGestureTypeNone,
	SBSystemGestureTypeShowNotificationCenter,
	SBSystemGestureTypeDismissBanner,
	SBSystemGestureTypeShowControlCenter,
	SBSystemGestureTypeSuspendApp,
	SBSystemGestureTypeSwitcherSlideUp,
	SBSystemGestureTypeSwitchApp,
	SBSystemGestureTypeSceneResize,
	SBSystemGestureTypeSideAppReveal,
	SBSystemGestureTypeSideAppGrabberReveal,
	SBSystemGestureTypeSideAppGrabberDismiss,
	SBSystemGestureTypeSideSwitcherReveal,
	SBSystemGestureTypeSideSwitcherGrabberPress,
	SBSystemGestureTypeSwitcherForcePress,
	SBSystemGestureTypeCarPlayBannerDismiss,
};

@class SBMainDisplaySystemGestureManager;

@interface SBSystemGestureManager : NSObject

+ (SBMainDisplaySystemGestureManager *)mainDisplayManager;

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer withType:(SBSystemGestureType)type;

@end
