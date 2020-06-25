@protocol BBDataProvider;

@interface BBLocalDataProviderStore : NSObject

- (void)addDataProvider:(id <BBDataProvider>)provider performMigration:(BOOL)performMigration;
- (void)addDataProvider:(id <BBDataProvider>)provider;

@end
