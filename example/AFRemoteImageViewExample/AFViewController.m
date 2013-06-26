//
//  AFViewController.m
//  AFRemoteImageViewExample
//
//  Created by Austin Fitzpatrick on 6/25/13.
//  Copyright (c) 2013 Austin Fitzpatrick. All rights reserved.
//

#import "AFViewController.h"
#import "AFRemoteImageView.h"

@interface AFViewController ()

@end

@implementation AFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int numRows = 4;
    int numCols = 3;
    CGFloat x = 0;
    CGFloat y = 0;
    for (int i = 0; i < numRows * numCols; i++){
        
        CGFloat width = 320 / numRows;
        CGFloat height = 480 / numCols;
        
        //just get a random image
        NSString *category = @[@"sports", @"people", @"abstract", @"animals"][arc4random() % 4];
        NSString *fileString = [NSString stringWithFormat:@"http://lorempixel.com/%d/%d/%@/%d", (int)width, (int)height, category, (i % 8) + 1];
        
        //create a bunch of remote image views with random images, allow them to load immediately.
        //if you want to delay the loading use the delayedLoading: parameter
        AFRemoteImageView *remoteImageView = [AFRemoteImageView remoteImageViewWithURL:[NSURL URLWithString:fileString]
                                                                       andSpinnerStyle:UIActivityIndicatorViewStyleWhiteLarge
                                                                      withExpectedSize:(CGSize){width,height}];
        [self.view addSubview:remoteImageView];
        //add them to the view immediately
        
        remoteImageView.frame = (CGRect){x,y,width,height};
        x+=width;
        if (x >= (width * numRows)){
            x = 0;
            y += height;
        }
    }
    
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
