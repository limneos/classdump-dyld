@class MKPlacemark;

@interface MKMapItem : NSObject

+ (NSArray *)mapItemsFromURL:(NSURL *)url options:(id *)options;
+ (NSURL *)urlForMapItems:(NSArray *)items options:(id)options;

@property (nonatomic, retain) MKPlacemark *placemark;
@property BOOL isCurrentLocation;

@end
