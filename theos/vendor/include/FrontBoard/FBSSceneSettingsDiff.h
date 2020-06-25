@class FBSSceneSettings;

@interface FBSSceneSettingsDiff : NSObject

+ (id)diffFromSettings:(FBSSceneSettings *)oldSettings toSettings:(FBSSceneSettings *)newSettings;

@end
