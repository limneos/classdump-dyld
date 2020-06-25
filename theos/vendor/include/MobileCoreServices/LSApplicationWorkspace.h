@interface LSApplicationWorkspace : NSObject

+ (instancetype)defaultWorkspace;

- (NSArray *)applicationsAvailableForHandlingURLScheme:(NSString *)urlScheme;
- (NSURL *)URLOverrideForURL:(NSURL *)url;

@end
