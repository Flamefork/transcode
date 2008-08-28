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

- (NSString *)transcode:(NSString *)aString;

- (void)callTranscode:(NSPasteboard *)pboard 
			 userData:(NSString *)userData 
				error:(NSString **)error;

@end
