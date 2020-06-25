@class FBScene;

static NSString *const kSBAppTagsHidden = @"hidden";

@interface SBApplication : NSObject

@property (nonatomic, retain, readonly) NSString *bundleIdentifier NS_AVAILABLE_IOS(8_0); // Technically available in iOS 5 as well (https://github.com/MP0w/iOS-Headers/blob/master/iOS5.0/SpringBoard/SBApplication.h#L143) and even iOS 4, but you probably don't want to use that (see: Camera/Photos).
@property (nonatomic, retain, readonly) NSString *displayName;
@property (nonatomic, retain, readonly) NSString *displayIdentifier NS_DEPRECATED_IOS(4_0, 8_0);

@property (nonatomic, retain, readonly) NSString *sandboxPath;
@property (nonatomic, retain, readonly) NSString *bundleContainerPath;
@property (nonatomic, retain, readonly) NSString *path;

@property (nonatomic, retain, setter=_setTags:) NSArray *tags;

- (NSNumber *)badgeNumberOrString;

- (FBScene *)mainScene;

- (BOOL)isRunning;

- (void)clearDeactivationSettings;

@end
