@interface SBAlertItem : NSObject

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode;
- (void)dismiss;

@property (nonatomic, retain) UIAlertView *alertSheet;

@end
