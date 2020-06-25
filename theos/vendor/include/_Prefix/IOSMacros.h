#define IS_IPAD ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define IN_SPRINGBOARD ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"])
#define IN_BUNDLE(bundleID) ([[NSBundle mainBundle].bundleIdentifier isEqualToString:bundleID])
