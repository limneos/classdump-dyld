@interface SBWiFiManager : NSObject

+ (instancetype)sharedInstance;

@property NSInteger signalStrengthBars;

@end
