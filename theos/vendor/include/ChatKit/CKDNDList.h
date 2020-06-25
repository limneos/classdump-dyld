@interface CKDNDList : NSObject

+ (instancetype)sharedList;

- (BOOL)isMutedChatIdentifier:(NSString *)identifier;

@end
