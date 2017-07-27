//
//  ViewController.h
//  iSearchPlay
//
//  Created by Park Jun Sung on 2016. 4. 28..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVYoutubePlayer.h"
@import GoogleMobileAds;
@import UIKit;
@class GADBannerView;

@interface YoutubeData :NSObject

@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, retain) NSDictionary *thumbnails;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *pageToken;

@end
@interface ViewController : UIViewController

@property (nonatomic, strong) JVYoutubePlayerView *player;
@property(nonatomic, weak) IBOutlet GADBannerView *bannerView;

@end

