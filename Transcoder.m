//
//  Transcoder.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Carbon/Carbon.h>

#import "CharMap.h"
#import "Transcoder.h"

@implementation Transcoder

- (NSString *)transcode:(NSString *)aString
{
	[self getKeyboardLayouts];
	
	return @"YO!";
}

- (NSDictionary *) getKeyboardLayouts
{
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	
	CFMutableDictionaryRef filter = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, NULL); 
	CFDictionaryAddValue(filter, kTISPropertyInputSourceType, kTISTypeKeyboardLayout);
	CFArrayRef list = TISCreateInputSourceList(filter, false);
	
	CFIndex i, c = CFArrayGetCount(list);
	
	for (i = 0; i < c; i++) {
		TISInputSourceRef isr = (TISInputSourceRef) CFArrayGetValueAtIndex(list, i);
		NSString *isid = (NSString*)TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyInputSourceID);
		
		CFDataRef uchr = TISGetInputSourceProperty((TISInputSourceRef)isr, kTISPropertyUnicodeKeyLayoutData);
		UCKeyboardLayout *uchrData = (UCKeyboardLayout*)CFDataGetBytePtr(uchr);
		
		NSMutableArray *arr = [[NSMutableArray alloc] init];
		
		UniCharCount maxStringLength = 4, actualStringLength;
		UniChar unicodeString[4];
		UInt32 deadKeyState;
		NSUInteger k;
		for (k = 0; k < 127; k++) {
			UCKeyTranslate(uchrData, k, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, unicodeString);
			NSString *c = [NSString stringWithCharacters:unicodeString length:actualStringLength];
			[arr insertObject:c atIndex:k];
		}
		
		[result setObject:arr forKey:isid];
	}
	
	for (NSString *k in result) {
		NSLog(k);
		NSArray *a = [result objectForKey:k];
		NSUInteger k;
		for (k = 0; k < 127; k++) {
			NSLog([NSString stringWithFormat:@"%d", k]);
			NSLog([a objectAtIndex:k]);
		}
	}
	
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
