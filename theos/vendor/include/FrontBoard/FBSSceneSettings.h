@interface FBSSceneSettings : NSObject

@property (getter=isBackgrounded, nonatomic, readonly) BOOL backgrounded;

@property (getter=isEffectivelyBackgrounded, nonatomic, readonly) BOOL effectivelyBackgrounded;

- (instancetype)initWithSettings:(FBSSceneSettings *)settings;

@end
