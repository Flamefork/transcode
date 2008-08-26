//
//  Transcoder.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Transcoder.h"
#import "Layout.h"

@implementation Transcoder

- (NSString *)transcode:(NSString *)aString
{
	[Layout createLayouts];
	
	return @"YO!";
}

- (void)callTranscode:(NSPasteboard *)pboard 
			 userData:(NSString *)userData 
				error:(NSString **)error 
{ 
	NSString *pboardString; 
	NSString *newString; 
	NSArray *types; 
	types = [pboard types]; 
	if (![types containsObject:NSStringPboardType]) { 
		*error = @"Error: couldn't transcode text.";
		return; 
	} 
	pboardString = [pboard stringForType:NSStringPboardType]; 
	if (!pboardString) { 
		*error = @"Error: couldn't transcode text.";
		return; 
	} 
	newString = [self transcode:pboardString]; 
	if (!newString) { 
		*error = @"Error: couldn't transcode text.";
		return; 
	} 
	types = [NSArray arrayWithObject:NSStringPboardType]; 
	[pboard declareTypes:types owner:nil]; 
	[pboard setString:newString forType:NSStringPboardType]; 
	return; 
}

@end
