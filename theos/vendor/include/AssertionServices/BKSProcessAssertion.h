typedef NS_ENUM(NSUInteger, BKSProcessAssertionReason)
{
    BKSProcessAssertionReasonNone = 0,
    BKSProcessAssertionReasonAudio = 1,
    BKSProcessAssertionReasonLocation = 2,
    BKSProcessAssertionReasonExternalAccessory = 3,
    BKSProcessAssertionReasonFinishTask = 4,
    BKSProcessAssertionReasonBluetooth = 5,
    BKSProcessAssertionReasonNetworkAuthentication = 6,
    BKSProcessAssertionReasonBackgroundUI = 7,
    BKSProcessAssertionReasonInterAppAudioStreaming = 8,
    BKSProcessAssertionReasonViewServices = 9,
    BKSProcessAssertionReasonNewsstandDownload = 10,
    BKSProcessAssertionReasonBackgroundDownload = 11,
    BKSProcessAssertionReasonVOiP = 12,
    BKSProcessAssertionReasonExtension = 13,
    BKSProcessAssertionReasonContinuityStreams = 14,
    // 15-9999 unknown
    BKSProcessAssertionReasonActivation = 10000,
    BKSProcessAssertionReasonSuspend = 10001,
    BKSProcessAssertionReasonTransientWakeup = 10002,
    BKSProcessAssertionReasonVOiP_PreiOS8 = 10003,
    BKSProcessAssertionReasonPeriodicTask_iOS8 = BKSProcessAssertionReasonVOiP_PreiOS8,
    BKSProcessAssertionReasonFinishTaskUnbounded = 10004,
    BKSProcessAssertionReasonContinuous = 10005,
    BKSProcessAssertionReasonBackgroundContentFetching = 10006,
    BKSProcessAssertionReasonNotificationAction = 10007,
    // 10008-49999 unknown
    BKSProcessAssertionReasonFinishTaskAfterBackgroundContentFetching = 50000,
    BKSProcessAssertionReasonFinishTaskAfterBackgroundDownload = 50001,
    BKSProcessAssertionReasonFinishTaskAfterPeriodicTask = 50002,
    BKSProcessAssertionReasonAFterNoficationAction = 50003,
    // 50004+ unknown
};

typedef NS_ENUM(NSUInteger, ProcessAssertionFlags)
{
    BKSProcessAssertionFlagNone = 0,
    BKSProcessAssertionFlagPreventSuspend         = 1 << 0,
    BKSProcessAssertionFlagPreventThrottleDownCPU = 1 << 1,
    BKSProcessAssertionFlagAllowIdleSleep         = 1 << 2,
    BKSProcessAssertionFlagWantsForegroundResourcePriority  = 1 << 3
};

@interface BKSProcessAssertion : NSObject

- (instancetype)initWithPID:(NSInteger)pid flags:(NSUInteger)flags reason:(NSUInteger)reason name:(NSString *)name withHandler:(id)handler;

+ (NSString *)NameForReason:(NSUInteger)reason;

- (BOOL)valid;

@end
