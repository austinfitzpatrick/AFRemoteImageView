//
//  RemoteImageView.h
//  Austin Fitzpatrick
//
//  Created by Austin J Fitzpatrick on 12/13/12.
//  Copyright (c) 2012 Austin J Fitzpatrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFRemoteImageViewDelegate.h"

/**
 *  An enum for the type of remote image view this represents (silent, progress bar, spinner, or placeholder)
 */
typedef enum{
    SpinUntilLoaded,
    ProgressBarUntilLoaded,
    PlaceholderUntilLoaded,
    SilentUntilLoaded
} RemoteImageViewLoadingType;

@interface AFRemoteImageView : UIView <NSURLConnectionDataDelegate>

/**
 *  The type of remote image view this represents (silent, progress bar, spinner, or placeholder)
 */
@property RemoteImageViewLoadingType loadingType;

/**
 *  The inner UIImageView that will hold the loaded image.  Useful for copying in memory or whatever else you might
 *  need a genuine UIImageView for.
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 *  The UIImage to use as a placeholder image if loadingType is set to PlaceholderUntilLoaded.  This image will appear
 *  instead of a loading spinner or progress bar.  It is ideal to make this image the same size and shape as the image
 *  you are downloading - when it is possible to know.
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 *  The UIProgressView representing the progress bar for this image if loadingType is set to ProgressBarUntilLoaded
 */
@property (nonatomic, strong) UIProgressView *progressView;

/**
 *  The UIActivityIndicatorView representing the spinner for this image if loadingType is set to SpinUntilLoaded
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

/**
 *  The URL for the image being loaded.
 */
@property (nonatomic, strong) NSURL *url;

/**
 *  The spinner style if loadingType is set to SpinUntilLoaded
 */
@property UIActivityIndicatorViewStyle spinnerStyle;
/**
 *  The progress bar style if loadingType is set to ProgressBarUntilLoaded
 */
@property UIProgressViewStyle progressBarStyle;

/**
 *  By offering an expected size the spinner or progress bar can be centered in the area eventually covered by the image.
 */
@property (nonatomic) CGSize expectedSize;

/**
 *  A delegate is optional but enables getting notification of when the image is fully loaded.
 */
@property (nonatomic, unsafe_unretained) id<RemoteImageViewDelegate> delegate;

/**
 *  Whether or not this image waits for a "beginLoading" call to begin loading (rather than starting on init)
 */
@property (readonly) BOOL delayedLoading;

/**
 *  The image offset defines where in the AFRemoteImageView the inner UIImageView will reside.  {0,0} by default and will typically be so.
 */
@property CGPoint imageOffset;

/**
 *  A set of initializers for instantiating remoteImageViews that load immediately and have no delegate.
 */
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andPlaceholderImage:(UIImage*) placeholderImage_ withExpectedSize:(CGSize) size;
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andSpinnerStyle:(UIActivityIndicatorViewStyle) spinnerStyle_ withExpectedSize:(CGSize) size;
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL *)url_ andProgressBarStyle:(UIProgressViewStyle) progressBarStyle_ withExpectedSize:(CGSize) size;

/**
 *  A set of initializers for instantiating remoteImageViews that load immediately and have a delegate.
 */
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andPlaceholderImage:(UIImage*) placeholderImage_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_;
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andSpinnerStyle:(UIActivityIndicatorViewStyle) spinnerStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_;
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL *)url_ andProgressBarStyle:(UIProgressViewStyle) progressBarStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_;

/**
 *  A set of initializers for instantiating remoteImageViews that wait for a call to beginLoading and have a delegate.
 */
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andPlaceholderImage:(UIImage*) placeholderImage_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_ delayedLoading:(BOOL) delayedLoading_;
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL*) url_ andSpinnerStyle:(UIActivityIndicatorViewStyle) spinnerStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_ delayedLoading:(BOOL) delayedLoading_;
+(AFRemoteImageView*) remoteImageViewWithURL:(NSURL *)url_ andProgressBarStyle:(UIProgressViewStyle) progressBarStyle_ withExpectedSize:(CGSize) size andDelegate:(id<RemoteImageViewDelegate>) delegate_ delayedLoading:(BOOL) delayedLoading_;


/**
 *  Manually begin loading this remote image view (used when delayedLoading is set to YES)
 */
-(void) beginLoading;

/**
 *  Manually empties the cache.  This shouldn't often be necessary as the cache is implemented as an NSCache object
 *  and will be automatically culled as memory usage becomes too high.  Still, if the application is using more
 *  memory than you'd like you can call this to remove images from the cache.
 */
+(void) emptyCache;



@end
