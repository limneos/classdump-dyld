/*
 * ipodimport.h
 * libipodimport
 *
 * iPod library import support library
 * Created by Arpad Goretity on 24/09/2012.
 *
 * Licensed under the 3-clause BSD License
 * (See LICENSE for furhter information)
 */

#ifndef __IPODIMPORT_H__
#define __IPODIMPORT_H__


@interface SSDownloadStatus : NSObject  {
    int padding[64];	// 44 = 0x2c
    //  SSDownloadPhase *_activePhase;	// 4 = 0x4
    BOOL _contentRestricted;	// 8 = 0x8
    NSError *_error;	// 12 = 0xc
    BOOL _failed;	// 16 = 0x10
    BOOL _paused;	// 17 = 0x11
}

@property(retain, nonatomic) NSError *error;
@property(assign, nonatomic, getter=isFailed) BOOL failed;
@property(readonly, assign, nonatomic) float percentComplete;
@end

@interface SSDownload : NSObject  {
        int padding[128];	// 44 = 0x2c
}
@property(retain, nonatomic) SSDownloadStatus *status;

- (void)setDownloadHandler:(id)handler completionBlock:(id)block;
- (id)initWithDownloadMetadata:(id)downloadMetadata;
@end

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface SSDownloadMetadata : NSObject
{
    int padding[128];	// 44 = 0x2c
}
@property (copy) NSString* bundleIdentifier;
@property(retain) NSString *genre;
@property(retain) NSString *title;
@property(retain) NSDate *releaseDate;
@property(retain) NSURL *primaryAssetURL;
@property(copy) NSString *artistName;
@property(retain) id purchaseDate;
@property(retain) id collectionName;
@property(retain) NSString *copyright;
@property(retain) NSString *kind;
@property(retain) id viewStoreItemURL;

- (id)initWithDictionary:(id)dictionary;
@end
@interface IPodLibraryItem : NSObject
@property (copy) SSDownloadMetadata* itemMetadata;
@property (copy) NSString* itemDownloadIdentifier;
@end




@interface SSDownloadManager : NSObject {
    
            int padding[128];	// 44 = 0x2c
    
}
@property(readonly, assign) NSArray *activeDownloads;	// G=0x2babb5e5;
@property(readonly, assign) NSArray *downloads;	// G=0x2babbb19;

@end

@interface SSDownloadQueue : NSObject
{
        int padding[128];	// 44 = 0x2c
}
@property(readonly, assign) SSDownloadManager *downloadManager;
+ (id)mediaDownloadKinds;
- (id)initWithDownloadKinds:(id)downloadKinds;
- (BOOL)addDownload:(id)download;
@end



#endif /* __IPODIMPORT_H__ */
