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
	return (NSString*)TISGetInputSourceProperty(TISCopyCurrentKeyboardLayoutInputSource(), kTISPropertyInputSourceID);
}

- (void) createLayouts
{
	layouts = [NSMutableArray array];
	[layouts retain];
	
	NSDictionary *filter = [NSDictionary dictionaryWithObject:(NSString *)kTISTypeKeyboardLayout forKey:(NSString *)kTISPropertyInputSourceType];
	NSArray *list = (NSArray *)TISCreateInputSourceList((CFDictionaryRef)filter, false);
	
	for (id *isr in list) {
		NSString *isid = (NSString*)TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyInputSourceID);
		
		CFDataRef uchr = TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyUnicodeKeyLayoutData);
		UCKeyboardLayout *uchrData = (UCKeyboardLayout*)CFDataGetBytePtr(uchr);
		
		Layout *layout = [[Layout alloc] initWithUchrData:uchrData lid:isid];
		
		[layouts addObject:layout];
	}
}

- (NSArray *)transcode:(NSString *)aString
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[aString length]];
	
	int currentIndex = [layouts indexOfObject:[self getCurrentLayoutID]];
	
	Layout *currentLayout = [layouts objectAtIndex:currentIndex];
	
	UniChar uchar;
	
	int i, length = [aString length];
	
	for (i = 0; i < length; i++) {
		uchar = [aString characterAtIndex:i];
		NSString *s = [NSString stringWithCharacters:&uchar length:1];
		KeyDiscriminant *kd = [currentLayout discriminantForChar:s];
		
		// Do not forward if we're in really wrong ;) layout
		if (!kd) return result;
		
		[result addObject:kd];
	}
	
	return result;
}

- (void) switchLayout
{
	int currentIndex = [layouts indexOfObject:[self getCurrentLayoutID]];
	
	int nextIndex = currentIndex + 1;
	if (nextIndex >= [layouts count]) nextIndex = 0;
	
	Layout *nextLayout = [layouts objectAtIndex:nextIndex];
	
	NSDictionary *filter = [NSDictionary dictionaryWithObject:nextLayout->layoutID forKey:(NSString *)kTISPropertyInputSourceID];
	CFArrayRef list = TISCreateInputSourceList((CFDictionaryRef)filter, false);
	TISSelectInputSource((TISInputSourceRef)CFArrayGetValueAtIndex(list, 0));
	
}

@end
