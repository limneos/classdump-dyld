#import "HBLOHandlerDelegate.h"

@interface HBLOHandler : NSObject <HBLOHandlerDelegate>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *identifier;

@property (nonatomic, retain) NSBundle *preferencesBundle;
@property (nonatomic, retain) NSString *preferencesClass;

- (id)openURL:(NSURL *)url sender:(NSString *)sender;

@end
