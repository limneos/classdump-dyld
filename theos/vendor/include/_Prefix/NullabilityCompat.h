#if !__has_feature(nullability)
	#define NS_ASSUME_NONNULL_BEGIN
	#define NS_ASSUME_NONNULL_END
	#define nullable
	#define nonnull
	#define _Nullable
	#define _Nonnull
#endif
