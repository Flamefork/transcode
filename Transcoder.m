//
//  Transcoder.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
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

- (void) createLayouts
{
	layouts = [NSMutableArray array];
	[layouts retain];
	
	NSDictionary *filter = [NSDictionary dictionaryWithObject:kTISTypeKeyboardLayout forKey:kTISPropertyInputSourceType];
	NSArray *list = TISCreateInputSourceList(filter, false);
	
	for (id *isr in list) {
		NSString *isid = (NSString*)TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyInputSourceID);
		
		CFDataRef uchr = TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyUnicodeKeyLayoutData);
		UCKeyboardLayout *uchrData = (UCKeyboardLayout*)CFDataGetBytePtr(uchr);
		
		Layout *layout = [[Layout alloc] initWithUchrData:uchrData lid:isid];
		
		[layouts addObject:layout];
	}
}

- (NSString *)transcode:(NSString *)aString
{
	NSMutableString *result = [NSMutableString string];
	
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

@end
