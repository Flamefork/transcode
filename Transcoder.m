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

- (NSString *) getCurrentLayoutID
{
	TISInputSourceRef isr = TISCopyCurrentKeyboardLayoutInputSource();
	return (NSString*)TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyInputSourceID);
}

- (void) setLayout:(NSString *)layoutID
{
	NSDictionary *filter = [NSDictionary dictionaryWithObject:layoutID forKey:kTISPropertyInputSourceID];
	NSArray *list = TISCreateInputSourceList(filter, false);
	TISInputSourceRef isr = [list objectAtIndex:0];
	TISSelectInputSource(isr);
}

- (NSArray *) createLayouts
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSDictionary *filter = [NSDictionary dictionaryWithObject:kTISTypeKeyboardLayout forKey:kTISPropertyInputSourceType];
	NSArray *list = TISCreateInputSourceList(filter, false);
	
	for (id *isr in list) {
		NSString *isid = (NSString*)TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyInputSourceID);
		
		CFDataRef uchr = TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyUnicodeKeyLayoutData);
		UCKeyboardLayout *uchrData = (UCKeyboardLayout*)CFDataGetBytePtr(uchr);
		
		Layout *layout = [[Layout alloc] initWithUchrData:uchrData lid:isid];
		
		[result addObject:layout];
	}
	
	return result;
}

- (NSString *)transcode:(NSString *)aString
{
	NSMutableString *result = [NSMutableString string];
	
	NSArray *layouts = [self createLayouts];
	NSString *current = [self getCurrentLayoutID];
	
	int currentIndex = -1, i, c = [layouts count];
	for (i = 0; i < c; i++) {
		Layout *lay = [layouts objectAtIndex:i];
		if (lay->layoutID == current) {
			currentIndex = i;
		}
	}
	int nextIndex = currentIndex + 1;
	if (nextIndex >= c) {
		nextIndex = 0;
	}
	Layout *currentLayout = [layouts objectAtIndex:currentIndex];
	Layout *nextLayout = [layouts objectAtIndex:nextIndex];
	
	UniChar uchar;
	CFStringRef str;
	
	int length = [aString length];
	for (i=0; i < length; i++) {
		uchar = [aString characterAtIndex:i];
		NSString *s = [NSString stringWithCharacters:&uchar length:1];
		KeyDiscriminant *kd = [currentLayout discriminantForChar:s];
		if (kd) {
			result = [result stringByAppendingString:[nextLayout charForDiscriminant:kd]];
		} else {
			result = [result stringByAppendingString:s];
		}
	}
	
	[self setLayout:nextLayout->layoutID];
	
	return result;
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
