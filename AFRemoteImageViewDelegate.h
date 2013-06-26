//
//  AFRemoteImageViewDelegate.h
//  AFRemoteImageViewExample
//
//  Created by Austin Fitzpatrick on 6/25/13.
//  Copyright (c) 2013 Austin Fitzpatrick. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFRemoteImageView;

@protocol RemoteImageViewDelegate <NSObject>

-(void) remoteImageViewDidFinishLoading:(AFRemoteImageView*) remoteImageView;

@end