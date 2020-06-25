@class BBSectionInfo;

@protocol BBDataProvider <NSObject>

@required

- (NSArray *)bulletinsFilteredBy:(NSUInteger)by count:(NSUInteger)count lastCleared:(NSDate *)cleared;
- (NSString *)sectionIdentifier;
- (NSArray *)sortDescriptors;

@optional

- (BBSectionInfo *)defaultSectionInfo;
- (NSString *)sectionDisplayName;
- (NSArray *)sortDescriptors;

- (void)noteSectionInfoDidChange:(BBSectionInfo *)sectionInfo;

@end
