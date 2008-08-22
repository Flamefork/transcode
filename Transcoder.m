//
//  Transcoder.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CharMap.h"
#import "Transcoder.h"

@implementation Transcoder

- (NSString *)transcode:(NSString *)aString
{
	CharMap *eng = [[CharMap alloc] initWithString:@"abcdefg"];
	CharMap *rus = [[CharMap alloc] initWithString:@"абцдефг"];
	
	NSString *newString = [aString mutableCopy];
	unsigned i = 0;
	unsigned length = [newString length];
	
	for (i = 0; i < length; i++) {
		
	}
	
	return newString;
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
