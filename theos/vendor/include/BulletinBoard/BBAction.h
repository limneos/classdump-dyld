@interface BBAction : NSObject

+ (instancetype)action;
+ (instancetype)actionWithLaunchBundleID:(NSString *)bundleID callblock:(id)block;
+ (instancetype)actionWithLaunchURL:(NSURL *)url callblock:(id)block;

@property (nonatomic, retain) NSString *bundleID;

@end
