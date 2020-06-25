@interface MPUNowPlayingController : NSObject

- (void)startUpdating;

@property BOOL shouldUpdateNowPlayingArtwork;

@property (nonatomic, readonly) UIImage *currentNowPlayingArtwork;

@end
