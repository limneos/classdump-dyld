@interface CKConversation : NSObject

@property (nonatomic, retain, readonly) NSString *uniqueIdentifier;
@property (nonatomic, readonly, retain) NSString *name;

@property (readonly) BOOL _chatSupportsTypingIndicators;
@property (readonly) BOOL isGroupConversation;

@end
