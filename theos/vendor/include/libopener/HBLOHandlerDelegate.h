@protocol HBLOHandlerDelegate <NSObject>

/**
 * Name of the handler, shown in Settings.
 */
@property (nonatomic, retain) NSString *name;

/**
 * Identifier of the handler, used internally by libopener.
 *
 * To prevent conflicts, use a reverse DNS name, such as your package's identifier. If your handler
 * previously supported libopener versions prior to 2.0, use the name you passed to
 * -[HBLibOpener registerHandlerWithName:block:].
 */
@property (nonatomic, retain) NSString *identifier;

/**
 * Custom Preferences list controller bundle.
 *
 * If nil, a switch will be shown in Settings, and enabled state is handled by libopener. Otherwise,
 * tapping the cell will push your list controller, and enabled state is handled by your code.
 *
 * @see preferencesClass
 */
@property (nonatomic, retain) NSBundle *preferencesBundle;

/**
 * Custom Preferences list controller class.
 *
 * Refer to preferencesBundle for more details. If this is nil, the principal class of the bundle
 * will be used.
 *
 * @see preferencesBundle
 */
@property (nonatomic, retain) NSString *preferencesClass;

/**
 * Called when a URL is opened in order to check if your handler wants to override the URL.
 *
 * @param url The original URL that the user wants to open.
 * @param sender The bundle identifier of the app that invoked the URL open request. Not reliable
 * on iOS 5.
 * @returns An NSURL that will be opened instead of the original, an NSArray of NSURLs for multiple
 * apps, or nil to not change the URL.
 */
- (id)openURL:(NSURL *)url sender:(NSString *)sender;

@end
