//
//  Transcoder.h
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Transcoder : NSObject
{
	NSMutableArray *layouts;
}

- (void) createLayouts;

- (NSArray *)decode:(NSString *)aString;

- (NSString *)encode:(NSArray *)keyDiscriminants;

- (void) switchLayout;

@end
