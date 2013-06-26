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
    switch (self.loadingType) {
        case ProgressBarUntilLoaded:
            self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:self.progressBarStyle];
            [self addSubview:self.progressView];
            self.progressView.center = (CGPoint){self.expectedSize.width / 2, self.expectedSize.height / 2};
            break;
        case SpinUntilLoaded:
            self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.spinnerStyle];
            self.activityIndicatorView.center = (CGPoint){self.expectedSize.width / 2, self.expectedSize.height / 2};
            [self addSubview:self.activityIndicatorView];
            [self.activityIndicatorView startAnimating];
            break;
        case PlaceholderUntilLoaded:
            self.imageView.image = self.placeholderImage;
            break;
        case SilentUntilLoaded:
            
            break;
    }
}




-(void) beginLoading{
    if (self.connection != nil) [NSException raise:@"Can not begin loading more than once." format:@"Loading already in progress, do not call beginLoading again."];

    
    self.imageView = [[UIImageView alloc] initWithImage:nil];
    self.imageView.frame = (CGRect) {self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.expectedSize.width, self.expectedSize.height};
    self.frame = (CGRect){self.frame.origin.x, self.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height};
    [self addSubview:self.imageView];

    
    
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
    
    if ([cache objectForKey:self.url] != nil){
        self.imageView.image = [cache objectForKey:self.url];
        [self.progressView removeFromSuperview];
        [self.activityIndicatorView removeFromSuperview];
        [self.delegate remoteImageViewDidFinishLoading:self];
        [currentyDownloading removeObject:self];
        if ([remoteImageViewQueue count] > 0) [[remoteImageViewQueue objectAtIndex:0] startDownloading];
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.0f];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self.connection start];

}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

-(void) updateProgressBar:(CGFloat) percentage{
    if (self.loadingType != ProgressBarUntilLoaded) return; //guard statement
    [self.progressView setProgress:percentage animated:YES];
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
    [self.imageView setFrame:(CGRect){self.imageOffset.x,self.imageOffset.y,self.frame.size.width, self.frame.size.height}];
}

+(UIImage*) cachedImageForURL:(NSURL*) url{
    if ([cache objectForKey:url] != nil) return [cache objectForKey:url];
    else return nil;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
    self.imageView.image = [UIImage imageWithData:self.data];

    [self.progressView removeFromSuperview];
    [self.activityIndicatorView removeFromSuperview];
    [self.delegate remoteImageViewDidFinishLoading:self];
    [currentyDownloading removeObject:self];
    
    if (cache == nil) cache = [[NSCache alloc] init];
    if (self.imageView.image == nil) self.imageView.image = [[UIImage alloc] init];
    [cache setObject:self.imageView.image forKey:self.url];

    [self.imageView setFrame:(CGRect){self.imageOffset.x,self.imageOffset.y,self.frame.size.width, self.frame.size.height}];
    
    if ([remoteImageViewQueue count] > 0) [[remoteImageViewQueue objectAtIndex:0] startDownloading];
    
}


@end
