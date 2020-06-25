//
//  URLDownloader.h
//  iOS-URLDownloader
//
//  Created by Kristijan Sedlak on 7/21/11.
//  Copyright 2011 AppStrides. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLCredential.h"

@class URLDownloader;


#pragma mark -

typedef enum
{
	URLDownloaderStateInactive = 0,
	URLDownloaderStateConnecting = 1,
	URLDownloaderStateAuthenticating = 2,
	URLDownloaderStateStarted = 3,
	URLDownloaderStateDownloading = 4,
	URLDownloaderStateFinished = 5,
	URLDownloaderStateCanceled = 6
} 
URLDownloaderState;


#pragma mark -

@protocol URLDownloaderDelegate <NSObject>

@required
- (void)urlDownloader:(URLDownloader *)urlDownloader didFinishWithData:(NSData *)data;
- (void)urlDownloader:(URLDownloader *)urlDownloader didFailOnAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)urlDownloader:(URLDownloader *)urlDownloader didFailWithError:(NSError *)error;
- (void)urlDownloader:(URLDownloader *)urlDownloader didFailWithNotConnectedToInternetError:(NSError *)error;

@optional
- (void)urlDownloaderDidStart:(URLDownloader *)urlDownloader;
- (void)urlDownloaderDidCancelDownloading:(URLDownloader *)urlDownloader;
- (void)urlDownloader:(URLDownloader *)urlDownloader didReceiveData:(NSData *)data;
- (void)urlDownloader:(URLDownloader *)urlDownloader didChangeStateTo:(URLDownloaderState)state;

@end


#pragma mark -

@interface URLDownloader : NSObject
{
    id <URLDownloaderDelegate> delegate;

	NSURLConnection *urlConnection;
    NSURLResponse *urlResponse;
	NSMutableData *urlData;
    URLCredential *urlCredential;
    URLDownloaderState state;
    float						bytesReceived;
}

@property(retain) id <URLDownloaderDelegate> delegate;
@property(nonatomic, readonly) URLDownloaderState state;

+ (id)downloaderWithDelegate:(id)obj;
- (id)initWithDelegate:(id)obj;
- (void)download:(NSURLRequest *)request withCredential:(URLCredential *)credential;
- (void)cancel;
- (int)fullContentSize;
- (int)downloadedContentSize;
- (float)downloadCompleteProcent;

@end
