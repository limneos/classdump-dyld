@interface BBSectionInfo : NSObject

+ (instancetype)defaultSectionInfoForType:(NSUInteger)type;

@property NSUInteger notificationCenterLimit;
@property (nonatomic, retain) NSString *sectionID, *displayName;

@end
