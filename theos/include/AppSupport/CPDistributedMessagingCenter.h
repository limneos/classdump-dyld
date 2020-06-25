@interface CPDistributedMessagingCenter : NSObject

+ (CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;

- (BOOL)sendMessageName:(NSString*)name
			   userInfo:(NSDictionary*)info;

- (NSDictionary*)sendMessageAndReceiveReplyName:(NSString*)name
									   userInfo:(NSDictionary*)info;

- (NSDictionary*)sendMessageAndReceiveReplyName:(NSString*)name
									   userInfo:(NSDictionary*)info
										  error:(NSError**)error;

- (void)sendMessageAndReceiveReplyName:(NSString*)name
							  userInfo:(NSDictionary*)info
							  toTarget:(id)target
							  selector:(SEL)selector
							   context:(void*)context;

- (void)runServerOnCurrentThread;
- (void)runServerOnCurrentThreadProtectedByEntitlement:(id)entitlement;
- (void)stopServer;

- (void)registerForMessageName:(NSString*)messageName
						target:(id)target
					  selector:(SEL)selector;

- (void)unregisterForMessageName:(NSString*)messageName;

@end

