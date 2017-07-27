//
//  YoutubeParser.h
//  iSearchPlay
//
//  Created by Park Jun Sung on 2016. 4. 30..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YoutubeParser : NSObject

- (void)getVideoUrlForID:(NSString*)videoID;
- (void)getVideoUrlForID:(NSString*)videoID complete:(void (^)(NSArray*))block;

@end
