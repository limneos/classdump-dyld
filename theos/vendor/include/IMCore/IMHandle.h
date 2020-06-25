@class IMPerson;

@interface IMHandle : NSObject

@property (nonatomic, retain) NSString *_displayNameWithAbbreviation;

@property (nonatomic, retain) IMPerson *person;

@end
