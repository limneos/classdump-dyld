#import "UIStatusBarItemView.h"

@interface UIStatusBarForegroundStyleAttributes : NSObject

@property (nonatomic) CGFloat height;

- (UIFont *)textFontForStyle:(UIStatusBarItemViewTextStyle)style;

- (NSString *)expandedNameForImageName:(NSString *)imageName;
- (UIImage *)untintedImageNamed:(NSString *)name;

@property (nonatomic, retain) UIColor *tintColor;

@end
