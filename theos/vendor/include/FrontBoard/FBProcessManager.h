@class FBProcess;

@interface FBProcessManager : NSObject

+ (instancetype)sharedInstance;

- (FBProcess *)processForPID:(int)pid;

@end
