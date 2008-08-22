//
//  CharMap.h
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CharMap : NSObject

- (void)initWithString:(NSString *)s;
- (unsigned)indexOf:(NSString *)s;
- :(NSString *)atIndex:(unsigned)i;

@end
