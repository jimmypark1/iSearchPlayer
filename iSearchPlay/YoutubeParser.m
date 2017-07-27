//
//  YoutubeParser.m
//  iSearchPlay
//
//  Created by Park Jun Sung on 2016. 4. 30..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "YoutubeParser.h"

@interface YoutubeParser()
{
    NSMutableDictionary *_parameters;
}
@end


@implementation YoutubeParser


- (NSString*)stringByDecodingURLFormat:(NSString*)url
{
    NSString* ret;
    ret = [url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [ret stringByRemovingPercentEncoding];
}

- (NSDictionary*)getQueryComponent:(NSString*)input
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    for(NSString *keyValue in [input componentsSeparatedByString:@"&"])
    {
        NSArray *keyValueArray = [keyValue componentsSeparatedByString:@"="];
        if([keyValueArray count]<2)
        {
            continue;
        }
        ;
        NSString* key = [self stringByDecodingURLFormat:keyValueArray[0]];
        NSString* value = [self stringByDecodingURLFormat:keyValueArray[1]];
        
        NSLog(@"Key=%@ Value=%@",key,value);
        parameters[key]= value;
    }
    return parameters;
}

- (void)getVideoUrlForID:(NSString*)videoID
{
    // static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4";
    
    NSString *searchBaseURL =	@"http://www.youtube.com/get_video_info?video_id="	;
    NSString *infoURL = [NSString stringWithFormat:@"%@%@",searchBaseURL, videoID];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:infoURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               dispatch_group_t group = dispatch_group_create();
                                                               dispatch_group_enter(group);
                                                               
                                                               
                                                               NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                               NSLog(@"Data = %@",text);
                                                               
                                                               dispatch_group_leave(group);
                                                               
                                                               dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                                                               
                                                               NSDictionary *parts =  [self getQueryComponent:text];
                                                               NSString *videoTitle = parts[@"title"];
                                                               NSString *streamImage = parts[@"iurl"];
                                                               ;
                                                               NSLog(@"url_encoded_fmt_stream_map:%@ %", parts[@"url_encoded_fmt_stream_map"]);
                                                               
                                                               
                                                               
                                                               for(NSString *videoEndoingString in [parts[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","])
                                                               {
                                                                   NSMutableDictionary *videoComponents =  [self getQueryComponent:videoEndoingString];
                                                                   videoComponents[@"title"] = videoTitle;
                                                                   NSLog(@"videoComponents:%@",videoComponents);
                                                               }
                                                               
                                                           }
                                                           
                                                       }];
    [dataTask resume];
    
    
}

- (void)getVideoUrlForID:(NSString*)videoID complete:(void (^)(NSArray*))block
{
    // static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4";
    
    NSString *searchBaseURL =	@"http://www.youtube.com/get_video_info?video_id="	;
    NSString *infoURL = [NSString stringWithFormat:@"%@%@",searchBaseURL, videoID];
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:infoURL];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLSessionDataTask * dataTask =[defaultSession dataTaskWithRequest:urlRequest
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          // NSLog(@"Response:%@ %@\n", response, error);
                                                           if(error == nil)
                                                           {
                                                               dispatch_group_t group = dispatch_group_create();
                                                               dispatch_group_enter(group);
                                                               
                                                               
                                                               NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                             //  NSLog(@"Data = %@",text);
                                                               
                                                               dispatch_group_leave(group);
                                                               
                                                               dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                                                               
                                                               NSDictionary *parts =  [self getQueryComponent:text];
                                                               NSString *videoTitle = parts[@"title"];
                                                               NSString *streamImage = parts[@"iurl"];
                                                               
                                                               
                                                               NSMutableArray *arry = [[NSMutableArray alloc] init];
                                                               for(NSString *videoEndoingString in [parts[@"url_encoded_fmt_stream_map"] componentsSeparatedByString:@","])
                                                               {
                                                                   NSMutableDictionary *videoComponents =  [self getQueryComponent:videoEndoingString];
                                                                   videoComponents[@"title"] = videoTitle;
                                                                   videoComponents[@"thumbImage"] = streamImage;
                                                                   NSLog(@"videoComponents:%@",videoComponents);
                                                                   [arry addObject:videoComponents];
                                                               }
                                                               block(arry);
                                                               
                                                           }
                                                           
                                                       }];
    [dataTask resume];
    
    
}





@end
