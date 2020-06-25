@interface SBIcon : NSObject

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSString *leafIdentifier;

- (NSInteger)badgeValue;

@end
