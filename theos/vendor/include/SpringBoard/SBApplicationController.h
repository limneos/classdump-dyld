@class SBApplication, FBUIApplicationService;

@interface SBApplicationController : NSObject

+ (SBApplicationController *)sharedInstance;

- (SBApplication *)applicationWithDisplayIdentifier:(NSString *)bundleIdentifier;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)bundleIdentifier;
- (SBApplication *)applicationWithPid:(NSInteger)pid;

- (NSNumber *)badgeNumberOrString;

@property (nonatomic, retain) NSArray *allApplications;

- (void)applicationService:(FBUIApplicationService *)applicationService suspendApplicationWithBundleIdentifier:(NSString *)bundleIdentifier;

@end
