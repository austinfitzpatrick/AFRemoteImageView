//  RemoteImageView.m
//  StateOfFlux
//
//  Created by Austin J Fitzpatrick on 12/13/12.
//  Copyright (c) 2012 Austin J Fitzpatrick. All rights reserved.
//

#import "AFRemoteImageView.h"

@interface AFRemoteImageView ()

@property (nonatomic, retain) NSURLConnection *connection;
@property CGFloat expectedDownloadSize;
@property NSMutableData *data;
@property BOOL delayedLoading;

+(UIImage*) cachedImageForURL:(NSURL*) url;

@end

@implementation AFRemoteImageView

static NSMutableArray *remoteImageViewQueue;
static NSMutableArray *currentyDownloading;
static NSCache *cache;

NSInteger const kMaxSimultaneousDownloads = 1;

@synthesize spinnerStyle,activityIndicatorView,expectedSize,progressBarStyle,url,loadingType,imageView,progressView,placeholderImage,delegate, delayedLoading, imageOffset;


+(void) emptyCache{
    cache = nil;
}

+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andPlaceholderImage:(UIImage*) placeholderImage_ withExpectedSize:(CGSize) size{
    return [AFRemoteImageView remoteImageViewWithURL:url_ andPlaceholderImage:placeholderImage_ withExpectedSize:size andDelegate:nil];
}
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andSpinnerStyle:(UIActivityIndicatorViewStyle) spinnerStyle_ withExpectedSize:(CGSize) size{
    return [AFRemoteImageView remoteImageViewWithURL:url_ andSpinnerStyle:spinnerStyle_ withExpectedSize:size andDelegate:nil];
}
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL *)url_ andProgressBarStyle:(UIProgressViewStyle) progressBarStyle_ withExpectedSize:(CGSize) size{
    return [AFRemoteImageView remoteImageViewWithURL:url_ andProgressBarStyle:progressBarStyle_ withExpectedSize:size andDelegate:nil];
}

+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andPlaceholderImage:(UIImage*) placeholderImage_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_{
    return [AFRemoteImageView remoteImageViewWithURL:url_ andPlaceholderImage:placeholderImage_ withExpectedSize:size andDelegate:delegate_ delayedLoading:NO];
}
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andSpinnerStyle:(UIActivityIndicatorViewStyle) spinnerStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_{
    return [AFRemoteImageView remoteImageViewWithURL:url_ andSpinnerStyle:spinnerStyle_ withExpectedSize:size andDelegate:delegate_ delayedLoading:NO];
}
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL *)url_ andProgressBarStyle:(UIProgressViewStyle) progressBarStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_{
    return [AFRemoteImageView remoteImageViewWithURL:url_ andProgressBarStyle:progressBarStyle_ withExpectedSize:size andDelegate:delegate_ delayedLoading:NO];
}

+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andPlaceholderImage:(UIImage*) placeholderImage_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>)delegate_ delayedLoading:(BOOL) delayedLoading_{
    AFRemoteImageView *remoteImageView = [[AFRemoteImageView alloc] init];
    
    remoteImageView.delegate = delegate_;
    remoteImageView.loadingType = PlaceholderUntilLoaded;
    remoteImageView.placeholderImage = placeholderImage_;
    remoteImageView.url = url_;
    remoteImageView.expectedSize = size;
    remoteImageView.delayedLoading = delayedLoading_;
    remoteImageView.imageOffset = (CGPoint){0,0};
    
    [remoteImageView showLoadingIndicator];
    if (!remoteImageView.delayedLoading) [remoteImageView beginLoading];

    return remoteImageView;
}

+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andSpinnerStyle:(UIActivityIndicatorViewStyle) spinnerStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>)delegate_ delayedLoading:(BOOL) delayedLoading_{
    AFRemoteImageView *remoteImageView = [[AFRemoteImageView alloc] init];
    
    remoteImageView.delegate = delegate_;
    remoteImageView.loadingType = SpinUntilLoaded;
    remoteImageView.spinnerStyle = spinnerStyle_;
    remoteImageView.url = url_;
    remoteImageView.expectedSize = size;
    remoteImageView.delayedLoading = delayedLoading_;
    remoteImageView.imageOffset = (CGPoint){0,0};
    
    [remoteImageView showLoadingIndicator];
    if (!remoteImageView.delayedLoading) [remoteImageView beginLoading];

    return remoteImageView;
}

+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL *)url_ andProgressBarStyle:(UIProgressViewStyle) progressBarStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>)delegate_ delayedLoading:(BOOL) delayedLoading_{
    AFRemoteImageView *remoteImageView = [[AFRemoteImageView alloc] init];
    
    remoteImageView.delegate = delegate_;
    remoteImageView.loadingType = ProgressBarUntilLoaded;
    remoteImageView.progressBarStyle = progressBarStyle_;
    remoteImageView.url = url_;
    remoteImageView.expectedSize = size;
    remoteImageView.delayedLoading = delayedLoading_;
    remoteImageView.imageOffset = (CGPoint){0,0};
    
    [remoteImageView showLoadingIndicator];
    if (!remoteImageView.delayedLoading) [remoteImageView beginLoading];

    return remoteImageView;
}

-(void) showLoadingIndicator{
    switch (loadingType) {
        case ProgressBarUntilLoaded:
            progressView = [[UIProgressView alloc] initWithProgressViewStyle:progressBarStyle];
            [self addSubview:progressView];
            progressView.center = (CGPoint){expectedSize.width / 2, expectedSize.height / 2};
            break;
        case SpinUntilLoaded:
            activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:spinnerStyle];
            activityIndicatorView.center = (CGPoint){expectedSize.width / 2, expectedSize.height / 2};
            [self addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            break;
        case PlaceholderUntilLoaded:
            imageView.image = placeholderImage;
            break;
        case SilentUntilLoaded:
            
            break;
    }
}




-(void) beginLoading{
    if (self.connection != nil) [NSException raise:@"Can not begin loading more than once." format:@"Loading already in progress, do not call beginLoading again."];

    
    imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.frame = (CGRect) {imageView.frame.origin.x, imageView.frame.origin.y, expectedSize.width, expectedSize.height};
    self.frame = (CGRect){self.frame.origin.x, self.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height};
    [self addSubview:imageView];

    
    
    if (remoteImageViewQueue == nil){
        remoteImageViewQueue = [NSMutableArray arrayWithObject:self];
    }
    else{
        [remoteImageViewQueue addObject:self];
    }

    if (currentyDownloading == nil){
        currentyDownloading = [NSMutableArray array];
    }
    if ([currentyDownloading count] < kMaxSimultaneousDownloads){
        [self startDownloading];
    }
    
}

-(void) startDownloading{
    
    [remoteImageViewQueue removeObject:self];
    [currentyDownloading addObject:self];
    
    if ([cache objectForKey:url] != nil){
        self.imageView.image = [cache objectForKey:url];
        [progressView removeFromSuperview];
        [activityIndicatorView removeFromSuperview];
        [delegate remoteImageViewDidFinishLoading:self];
        [currentyDownloading removeObject:self];
        if ([remoteImageViewQueue count] > 0) [[remoteImageViewQueue objectAtIndex:0] startDownloading];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.0f];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection start];

}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

-(void) updateProgressBar:(CGFloat) percentage{
    if (loadingType != ProgressBarUntilLoaded) return; //guard statement
    [progressView setProgress:percentage animated:YES];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.expectedDownloadSize = [response expectedContentLength];
//    NSLog(@"%@", response);
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data_{
//    NSLog(@"%@", data_);
    if (self.data == nil) self.data = [NSMutableData dataWithData:data_];
    else             [self.data appendData:data_];
    [self updateProgressBar:(float) [self.data length] / (float) self.expectedDownloadSize];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    [imageView setFrame:(CGRect){imageOffset.x,imageOffset.y,self.frame.size.width, self.frame.size.height}];
}

+(UIImage*) cachedImageForURL:(NSURL*) url{
    if ([cache objectForKey:url] != nil) return [cache objectForKey:url];
    else return nil;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    self.imageView.image = [UIImage imageWithData:self.data];

    [progressView removeFromSuperview];
    [activityIndicatorView removeFromSuperview];
    [delegate remoteImageViewDidFinishLoading:self];
    [currentyDownloading removeObject:self];
    
    if (cache == nil) cache = [[NSCache alloc] init];
    if (self.imageView.image == nil) self.imageView.image = [[UIImage alloc] init];
    [cache setObject:self.imageView.image forKey:url];

    [imageView setFrame:(CGRect){imageOffset.x,imageOffset.y,self.frame.size.width, self.frame.size.height}];
    
    if ([remoteImageViewQueue count] > 0) [[remoteImageViewQueue objectAtIndex:0] startDownloading];
    
}


@end
