//
//  ViewController.m
//  iSearchPlay
//
//  Created by Park Jun Sung on 2016. 4. 28..
//  Copyright © 2016년 Junsoft. All rights reserved.
//
@import GoogleMobileAds;

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SphereMenu.h"
#import "Chameleon.h"
#import "EditViewCell.h"
#import "YoutubeParser.h"
#import "SearchCellTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LMMediaPlayerView.h"

@implementation YoutubeData

@end


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

static NSString const *api_key =@"AIzaSyAMfe_Mk3gecJ2EvRV0dEGibTofmPXyPt8"; // public youtube api key


@interface ViewController ()<GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>
{
    UISearchBar *_searchBar;
    __weak IBOutlet UICollectionView *collectionView;
    
    NSMutableArray *_datas;
    
    __weak IBOutlet UITableView *tableView;
    __weak IBOutlet UIView  *playerView;
    __weak IBOutlet UIView  *searchView;
    __weak IBOutlet UISearchBar *searchBar;
    LMMediaItem *item1;
    BOOL bOverSearchBar;

}
@property (nonatomic) int counter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL isInBackgroundMode;
@property (nonatomic, strong) SphereMenu *sphereMenu;

@property(nonatomic, strong) GADAdLoader *adLoader;


/// The native ad view that is being presented.
@property(nonatomic, strong) UIView *nativeAdView;

@end

@implementation ViewController

- (void)getDefaultList:(NSString*)pageToken
{
    //https://www.googleapis.com/youtube/v3/search?part=snippet&q=sports&maxResults=40&key=AIzaSyBqXp0Uo2ktJcMRpL_ZwF5inLTWZfsCYqY
    
    NSHTTPURLResponse *response = nil;
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    //  countryCode = @"kr";
    //regionCode
    //
  //  NSString *jsonUrlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=music&regionCode=jp&maxResults=40&safeSearch=none&key=AIzaSyBqXp0Uo2ktJcMRpL_ZwF5inLTWZfsCYqY"];
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=50&regionCode=%@&pageToken=%@&key=AIzaSyBqXp0Uo2ktJcMRpL_ZwF5inLTWZfsCYqY",countryCode,pageToken];
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error)
    {
                                          
        NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSString *pageToken = result[@"nextPageToken"];
        int i=0;
        for( NSDictionary *dict in result[@"items"])
        {
            YoutubeData *youtube = [[YoutubeData alloc] init];
           
            youtube.videoID = dict[@"id"];
            NSDictionary *snippet = dict[@"snippet"];
            youtube.title =  snippet[@"title"];
            NSDictionary *thumb = snippet[@"thumbnails"];
            youtube.thumbnails = thumb;
            youtube.pageToken = pageToken;
            [_datas addObject:youtube];
            
         
            i++;
          
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(i==1)
                {
                    [self.player loadPlayerWithVideoId:youtube.videoID];
                    
                    [self.view addSubview:self.player];
                    
                }
                [tableView reloadData];
            });
         
        }
        NSLog(@"result=%@", result);
        
       
    }];
    [downloadTask resume];
    
    
    
}

- (void)getSearchListForQuery:(NSString*)query pageToken:(NSString*)pageToken
{
    //https://www.googleapis.com/youtube/v3/search?part=snippet&q=sports&maxResults=40&key=AIzaSyBqXp0Uo2ktJcMRpL_ZwF5inLTWZfsCYqY
    
    NSHTTPURLResponse *response = nil;
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    //  countryCode = @"kr";
    //regionCode
    //
    
  //  NSString *jsonUrlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&regionCode=jp&maxResults=40&safeSearch=none&key=AIzaSyBqXp0Uo2ktJcMRpL_ZwF5inLTWZfsCYqY",query];
  
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&regionCode=%@&maxResults=50&safeSearch=none&pageToken=%@&key=AIzaSyAMfe_Mk3gecJ2EvRV0dEGibTofmPXyPt8",query, countryCode,pageToken];
    
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *responseData, NSURLResponse *response, NSError *error)
                                          {
                                              
                                              NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                                              NSString *pageToken = result[@"nextPageToken"];
                                              int i=0;
                                              for( NSDictionary *dict in result[@"items"])
                                              {
                                                  YoutubeData *youtube = [[YoutubeData alloc] init];
                                                  
                                                  youtube.videoID = dict[@"id"];
                                                  NSDictionary *snippet = dict[@"snippet"];
                                                  youtube.title =  snippet[@"title"];
                                                  NSDictionary *thumb = snippet[@"thumbnails"];
                                                  youtube.thumbnails = thumb;
                                                  youtube.pageToken = pageToken;
                                                  [_datas addObject:youtube];
                                                  
                                                  
                                                  i++;
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if(i==1)
                                                      {
                                                          [self.player loadPlayerWithVideoId:youtube.videoID];
                                                          
                                                          [self.view addSubview:self.player];
                                                          
                                                      }
                                                      [tableView reloadData];
                                                  });
                                                  
                                              }
                                              NSLog(@"result=%@", result);
                                              
                                              
                                          }];
    [downloadTask resume];
    
    
    
}

- (void)makeSearchBar
{
   // return;
    //_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    //_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.delegate = self;
   // [playerView addSubview:_searchBar];
 //   [tableView setContentOffset:CGPointMake(0, 44)];

}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    bOverSearchBar = YES;
 
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_datas removeAllObjects];
    [self getSearchListForQuery:searchBar.text pageToken:@""];
    bOverSearchBar = YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];

}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [_searchBar setText:@""];
    [_datas removeAllObjects];
    [self getDefaultList:@""];
    
    bOverSearchBar = NO;
    
    //getSearchListForQuery:(NSString*)query
    [_searchBar setShowsCancelButton:NO animated:YES];
    [_searchBar resignFirstResponder];
    [tableView reloadData];
    
}

- (void)playVideo:(NSURL*)url title:(NSString*)title
{
    
    LMMediaPlayerView *player = [LMMediaPlayerView sharedPlayerView];

    if(item1)
    {
        [ player.mediaPlayer removeMediaAtIndex:0];
    }
//    [playerView initWithFrame:playerView.frame];
    player.frame = CGRectMake(0, 0, playerView.frame.size.width, playerView.frame.size.height);
  //  player.contentMode = UIViewContentModeScaleToFill;
   // LMMediaPlayer *player = [LMMediaPlayer sharedPlayer];

    //[player.mediaPlayer stop];
    
    item1 = [[LMMediaItem alloc] initWithInfo:@{
                                                             LMMediaItemInfoURLKey:url,
                                                             LMMediaItemInfoContentTypeKey:@(LMMediaItemContentTypeVideo)
                                                             }];
  
    item1.title = title;
    
    //[player addMedia:item1];
    [player.mediaPlayer addMedia:item1];
    [playerView addSubview:player];
    
    [player.mediaPlayer play];
    
    
    /*
    MPMoviePlayerViewController *movieViewController = [[MPMoviePlayerViewController alloc] initWithContentURL: url];
    movieViewController.wantsFullScreenLayout = NO;
    movieViewController.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    [movieViewController.view setFrame:[playerView bounds]];
  //  [movieViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];

    [playerView addSubview:movieViewController.view];
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = [[NSMutableArray alloc] init];
    playerView.backgroundColor = [UIColor blackColor];
    [self getDefaultList:@""];
    bOverSearchBar = NO;
     // Do any additional setup after loading the view, typically from a nib.
   // self.versionLabel.text = [GADRequest sdkVersion];
    [collectionView registerClass:[EditViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self makeSearchBar];
 //   [self.navigationController setNavigationBarHidden:YES animated:YES];
    UIView *tempFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    
    [button addTarget:self
               action:@selector(refresh)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Load More" forState:UIControlStateNormal];
    button.frame = CGRectMake(10.0, 210.0, 160.0, 40.0);
    
    [tempFooter addSubview:button];
 
    NSDictionary *dict = NSDictionaryOfVariableBindings(button);
    [tempFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[button]-10-|" options:0 metrics:nil views:dict]];
    [tempFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|" options:0 metrics:nil views:dict]];
  
    tableView.tableFooterView = tempFooter;
    
     //ca-app-pub-2367841846534648/9275234817
    self.title = @"iSearchPlay";
    NSArray *colors = @[FlatBlueDark, FlatBlueDark, FlatNavyBlueDark, FlatNavyBlue];
    self.view.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                      withFrame:self.view.frame
                                                      andColors:colors];
    collectionView.backgroundColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom
                                                      withFrame:self.view.frame
                                                      andColors:colors];
    
    
    
   // [self.player loadPlayerWithVideoURL:@"https://www.youtube.com/watch?v=mIAgmyoAmmc"];
    
    [self.view addSubview:self.player];
    
    //ca-app-pub-8807882879991584/7498082196
    self.bannerView.adUnitID = @"ca-app-pub-8807882879991584/7498082196";
   //self.bannerView.adUnitID = @"ca-app-pub-2367841846534648/4638055615";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    /*
     request.testDevices = @[
     //
     @"ca8f54d4f237c1f1f447db562e6b991f97803261"  // Eric's iPod Touch
     ];
     */
    [self.bannerView loadRequest:request];   // [self.view addSubview:self.bannerView];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCellTableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchCellTableViewCell"] ;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    if([_datas count]>0 && ([indexPath row] == ([_datas count])))
    {
        cell.title.font = [UIFont fontWithName:@"Helvetica" size:20];
        cell.title.text = @"More";
        CGRect rect = cell.title.frame;
        rect.size.height = 30;
        cell.title.frame = rect;
        cell.imgView.hidden = YES;
    
    }
    else if([_datas count])
    {
        YoutubeData *youtube = _datas[[indexPath row]];
        cell.title.font = [UIFont fontWithName:@"Helvetica" size:10];
        cell.title.text = youtube.title;
        NSDictionary *thumbDict = youtube.thumbnails[@"default"];
        NSString *thumbURL = thumbDict[@"url"];
        
        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbURL]];
        UIImage *image = [UIImage imageWithData:data];
        
        cell.imgView.image = image;
        cell.imgView.contentMode = UIViewContentModeScaleToFill;
        
        
        cell.imgView.clipsToBounds = YES;
        cell.imgView.layer.cornerRadius = 6;
        cell.imgView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.imgView.layer.borderWidth =2;

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Load More" forState:UIControlStateNormal];
    button.frame = CGRectMake(10.0, 210.0, 160.0, 40.0);
    
    
    [headerView addSubview:button];
    
    
    return headerView;
    
}
*/

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y <= - 65.0f) {
        // fetch extra data & reload table view
        NSLog(@"");
    }
}

- (void)refresh
{
    if([_datas count] == 0)
        return;
    
    YoutubeData *youtube =_datas[[_datas count]-1];
    if(bOverSearchBar)
        [self getSearchListForQuery:_searchBar.text pageToken:youtube.pageToken];
    else
        [self getDefaultList:youtube.pageToken];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    {
        YoutubeData *youtube =_datas[[indexPath row]];
        
        NSString *url = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",youtube.videoID];
        // [self.player loadPlayerWithVideoURL:url];
        NSString *videoID = youtube.videoID;
        NSString *playlistId = @"";
        if([youtube.videoID isKindOfClass:[NSDictionary class]])
        {
            NSDictionary  *dict = youtube.videoID;
            NSString *kind = dict[@"kind"];
            if([kind containsString:@"playlist"])
            {
                //playlist
                playlistId = dict[@"playlistId"];
                videoID = nil;
            }
            else
                videoID = dict[@"videoId"];
        }
        [self.player setHd720:YES];
        if(videoID && [playlistId length] == 0)
            [self.player loadPlayerWithVideoId:videoID];
        else if(!videoID && [playlistId length])
            [self.player loadPlayerWithPlaylistId:playlistId];
        
        self.player.layer.zPosition = 1000;
        
        [self.view addSubview:self.player];
    }
 
  //  [self.view addSubview:self.sphereMenu];
    
    /*
    YoutubeParser *youtubeParser = [[YoutubeParser alloc] init];//YoutubeParser
    // [youtube getVideoUrlForID:@"ztcLm71ZL0A"];
    //- (void)getVideoUrlForID:(NSString*)videoID complete:(void (^)(NSDictionary*))block
    [youtubeParser getVideoUrlForID:youtube.videoID complete:^(NSArray* array){
      //  for( in array )
       //  NSDictionary* dict =    array[0];
        
        for(NSDictionary* dict in array )
        {
            NSLog(@"dict=%@",dict);
            NSString *url =  dict[@"url"];
            [self playVideo:[NSURL URLWithString:url] title:youtube.title];
            break;
        }
        
      
        
    }];
     */

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
    
    //[self requestSerachVideo];
    [self parse:@"sexy"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if(self.player.playerState == kJVPlayerStatePaused || self.player.playerState == kJVPlayerStateEnded || self.player.playerState == kJVPlayerStateUnstarted || self.player.playerState == kJVPlayerStateUnknown || self.player.playerState == kJVPlayerStateQueued || self.player.playerState == kJVPlayerStateBuffering)
                {
                    [self.player playVideo];
                }
                else {
                    [self.player pauseVideo];
                }
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self.player previousVideo];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self.player nextVideo];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Getters and Setters

- (JVYoutubePlayerView *)player
{
    if(!_player)
    {
        _player = [[JVYoutubePlayerView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, 234)];
        _player.delegate = self;
        _player.autoplay = NO;
        _player.modestbranding = YES;
        _player.allowLandscapeMode = YES;
        _player.forceBackToPortraitMode = NO;
        _player.allowAutoResizingPlayerFrame = YES;
        _player.playsinline = NO;
        _player.fullscreen = YES;
        _player.playsinline = YES;
        _player.allowBackgroundPlayback = YES;
        _player.navController = self.navigationController;
    }
    
    return _player;
}

- (SphereMenu *)sphereMenu
{
    if(!_sphereMenu)
    {
        UIImage *startImage = [UIImage imageNamed:@"start"];
        UIImage *image1 = [UIImage imageNamed:@"rewind"];
        UIImage *image2 = [UIImage imageNamed:@"player"];
        UIImage *image3 = [UIImage imageNamed:@"forward"];
        NSArray *images = @[image1, image2, image3];
        
        _sphereMenu = [[SphereMenu alloc] initWithStartPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-120) startImage:startImage submenuImages:images];
        _sphereMenu.delegate = self;
    }
    
    return _sphereMenu;
}


#pragma mark -
#pragma mark Player delegates

- (void)playerView:(JVYoutubePlayerView *)playerView didChangeToQuality:(JVPlaybackQuality)quality
{
    [_player setPlaybackQuality:kJVPlaybackQualityHD720];
}

//- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
//{
//    [self.player nextVideo];
//}


#pragma mark -
#pragma mark Helper Functions

- (void)sphereDidSelected:(int)index
{
    if(index == 1)
    {
        if(self.player.playerState == kJVPlayerStatePaused || self.player.playerState == kJVPlayerStateEnded || self.player.playerState == kJVPlayerStateUnstarted || self.player.playerState == kJVPlayerStateUnknown || self.player.playerState == kJVPlayerStateQueued || self.player.playerState == kJVPlayerStateBuffering)
        {
            [self.player playVideo];
        }
        else
        {
            [self.player pauseVideo];
            self.counter = 0;
        }
    }
    else if(index == 0)
    {
        [self.player previousVideo];
    }
    else
    {
        [self.player nextVideo];
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)playerViewDidBecomeReady:(JVYoutubePlayerView *)playerView
{
    // loading a set of videos to the player after the player has finished loading
    // NSArray *videoList = @[@"m2d0ID-V9So", @"c7lNU4IPYlk"];
    // [self.player loadPlaylistByVideos:videoList index:0 startSeconds:0.0 suggestedQuality:kJVPlaybackQualityHD720];
}

#pragma mark -
#pragma mark Notifications

- (void)appIsInBakcground:(NSNotification *)notification
{
    //    [self.player playVideo];
}

- (void)appWillBeInBakcground:(NSNotification *)notification
{
    // self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(keepPlaying) userInfo:nil repeats:YES];
    // self.isInBackgroundMode = YES;
    // [self.player playVideo];
}

- (void)keepPlaying
{
    if(self.isInBackgroundMode)
    {
        [self.player playVideo];
        self.isInBackgroundMode = NO;
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}


#pragma mark - testing request to youtube

- (void)parse:(NSString*)query
{
    NSHTTPURLResponse *response = nil;
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    //countryCode = @"kr//";
    NSString *jsonUrlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&q=%@&key=AIzaSyAMfe_Mk3gecJ2EvRV0dEGibTofmPXyPt8",query];
    NSURL *url = [NSURL URLWithString:[jsonUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // Callback, parse the data and check for errors
        if (data && !connectionError)
        {
            NSError *jsonError;
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (!jsonError)
            {
               // NSLog(@"Response from YouTube: %@", jsonResult);
                
                for(NSDictionary *itemDict in jsonResult[@"items"])
                {
                    NSDictionary *dictID      = itemDict[@"id"];
                    NSDictionary *dictSnippet = itemDict[@"id"];
                    NSString *videoID       = dictID[@"videoId"];
                    NSString *channelID     = dictSnippet[@"channelId"];
                    NSString *channelTitle  = dictSnippet[@"channelTitle"];
                    NSString *channelDesc   = dictSnippet[@"description"];
                    NSString *publishedAt   = dictSnippet[@"publishedAt"];
                    NSArray *thumbnails     = dictSnippet[@"thumbnails"];
                    
                    NSLog(@"dict: %@", itemDict);
                    
                }
            }
        }
    }];

    
}

- (void)requestSerachVideo
{
    // Set up your URL
    NSString *youtubeApi = @"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&q=sexy&key=AIzaSyAMfe_Mk3gecJ2EvRV0dEGibTofmPXyPt8";
    NSURL *url = [[NSURL alloc] initWithString:youtubeApi];
    
    // Create your request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Send the request asynchronously
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // Callback, parse the data and check for errors
        if (data && !connectionError)
        {
            NSError *jsonError;
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (!jsonError)
            {
                NSLog(@"Response from YouTube: %@", jsonResult);
            }
        }
    }];
    
    // from yelp
    //    NSURLRequest *searchRequest = [self searchRequestWithQuery:@"deep house"];
    //    NSURLSession *session = [NSURLSession sharedSession];
    //
    //    [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    //
    //        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    //
    //        if (!error && httpResponse.statusCode == kStatusCode)
    //        {
    //            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    //            NSLog(@"response %@", searchResponseJSON);
    //        }
    //        else
    //        {
    //            NSLog(@"error: %@", error);
    //        }
    //    }]
    //     resume];
}

// sample from http://stackoverflow.com/questions/30290483/how-to-use-youtube-api-v3-in-ios
//https://www.googleapis.com/youtube/v3/videos?part=contentDetails%2C+snippet%2C+statistics&id=AKiiekaEHhI&key={AIzaSyCVE43_3JbRU4qLPC7I4FGAQ0bdSELYEwU}
//- (NSURLRequest *)searchRequestWithQuery:(NSString *)query
//{
//    NSDictionary *parameters = @{@"part" : @"contentDetails+snippet+statistics",
//                                 @"id" : @"AKiiekaEHhI",
//                                 @"q": query,
//                                 @"maxResults": @"10"};
//
//    NSURLRequest *request = [NSURLRequest requestWithHost:@"www.googleapis.com/youtube" path:@"/v3/videos" parameters:parameters];
//    
//    return request;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 0;//[_feeds count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EditViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    return cell;
}


@end
