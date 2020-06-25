//
//  KBYTDownloadStream.h
//  Seas0nPass
//
//  Created by Kevin Bradley on 3/9/07.
//  Copyright 2007 nito, LLC. All rights reserved.
//

#import "KBYourTube.h"
#import "URLDownloader.h"
/**
 
 This class is used for downloading files from youtube, it takes care of fixing and multiplexing streams when necessary
 
 feed it a stream into downloadStream method and it will take care of the rest.
 
 */

@protocol KBYTDownloadStreamDelegate

- (void)downloadFinished:(NSString *)downloadFile;
- (void)downloadFailed:(NSString *)downloadFile;
- (void)setDownloadProgress:(double)theProgress;

@end


@interface KBYTDownloadStream : NSObject <URLDownloaderDelegate>  {
	
	//NSURLDownload				*urlDownload;
    NSURLResponse				*myResponse;
	float						bytesReceived;
	NSString					*downloadLocation;
	long long					updateFrequency;
	long long					freq;
    KBYTStream                  *audioStream;
    NSString                    *videoDownloadLocation;

}
@property (retain) URLDownloader *downloader;
@property (strong, atomic) void (^ProgressBlock)(double percentComplete);
@property (strong, atomic) void (^FancyProgressBlock)(double percentComplete, NSString *status);
@property (strong, atomic) void (^CompletedBlock)(NSString *downloadedFile);

typedef void(^DownloadProgressBlock)(double percentComplete);
typedef void(^FancyDownloadProgressBlock)(double percentComplete, NSString *downloadedFile);
typedef void(^DownloadCompletedBlock)(NSString *downloadedFile);

@property (nonatomic, retain) NSString *downloadLocation;
@property (readwrite, assign) NSInteger downloadMode; //0 = muxed file, 1 = demuxed tracks

- (void)downloadStream:(KBYTStream *)inputStream
              progress:(FancyDownloadProgressBlock)progressBlock
             completed:(DownloadCompletedBlock)completedBlock;


- (long long)updateFrequency;
- (void)setUpdateFrequency:(long long)newUpdateFrequency;
- (void)setDownloadResponse:(NSURLResponse *)response;
- (void)cancel;

@end
