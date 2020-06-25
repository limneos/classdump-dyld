#include <sys/cdefs.h>

@class BBBulletinRequest;
@protocol BBDataProvider;

@interface BBServer : NSObject

- (void)_addDataProvider:(id<BBDataProvider>)dataProvider sortSectionsNow:(BOOL)sortSections;

@end

__BEGIN_DECLS

extern void BBDataProviderAddBulletin(id<BBDataProvider> dataProvider, BBBulletinRequest *bulletinRequest);
extern void BBDataProviderWithdrawBulletinsWithRecordID(id<BBDataProvider> dataProvider, NSString *recordID);

__END_DECLS
