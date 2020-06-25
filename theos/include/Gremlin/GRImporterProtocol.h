/*
 * Created by Youssef Francis on September 25th, 2012.
 */

typedef BOOL (^GRImportOperationBlock)(NSDictionary*, NSError**);

@protocol GRImporter <NSObject>
+ (GRImportOperationBlock)newImportBlock;
@end

