#import "SBSystemGestureManager.h"

@interface SBScreenEdgePanGestureRecognizer : UIScreenEdgePanGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action type:(SBSystemGestureType)type;

@end
