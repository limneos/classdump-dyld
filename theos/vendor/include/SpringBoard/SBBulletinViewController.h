@class SBNotificationsBulletinInfo;

@interface SBBulletinViewController : UITableViewController

- (SBNotificationsBulletinInfo *)_bulletinInfoAtIndexPath:(NSIndexPath *)indexPath;

@end
