AFRemoteImageView
==============

AFRemoteImageView provides a "request and forget" method for retrieving images from the web.  Instead of having to download the image, create a UIImageView and then add it to the stage you can instead create an AFRemoteImageView and immediately add it to the stage.  A progress indiciator will be displayed until the image is completely loaded at which point it will appear.

AFRemoteImageView remembers all remote requests made and caches the results so that subesquent requests for the same image are completed immediately.

Requirements
------------

This class assumes that the internet connection is active and stable.  It should work on iOS 4.3 and above.

Example Use
-----------

Here is the most basic example of AFRemoteImageView fetching an image from the internet and displaying a spinner while it does.

    AFRemoteImageView *remoteImageView = [AFRemoteImageView remoteImageViewWithURL:[NSURL URLWithString:@"http://lorempixel.com/200/200"]
                                                                   andSpinnerStyle:UIActivityIndicatorViewStyleWhiteLarge
                                                                  withExpectedSize:(CGSize){200,200}];
	[self.view addSubview: remoteImageView];

You can request that AFRemoteImageView not begin loading immediately or add a delegate during creation as well.

    AFRemoteImageView *remoteImageView = [AFRemoteImageView remoteImageViewWithURL:[NSURL URLWithString:@"http://lorempixel.com/200/200"]
                                                               andSpinnerStyle:UIActivityIndicatorViewStyleWhiteLarge
                                                              withExpectedSize:(CGSize){200,200}
															       andDelegate:self
																delayedLoading:YES];
    [self.view addSubview: remoteImageView];
	//later...
	[remoteImageView beginLoading];