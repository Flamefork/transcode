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
//	CharMap *eng = [[CharMap alloc] initWithString:@"abcdefg"];
//	CharMap *rus = [[CharMap alloc] initWithString:@"абцдефг"];
//
//	NSString *newString = [aString mutableCopy];
//	unsigned i = 0;
//	unsigned length = [newString length];
//	
//	for (i = 0; i < length; i++) {
//		
//	}
//	
//	return newString;
	
	KeyboardLayoutRef currentLayout;
    OSStatus err = KLGetCurrentKeyboardLayout( &currentLayout );
	
    SInt32		keyLayoutKind;
    UInt32		deadKeyState;
    UCKeyboardLayout	*uchrData;
	
	err = KLGetKeyboardLayoutProperty( currentLayout, kKLKind, (const void **)&keyLayoutKind );
	if (keyLayoutKind != kKLKCHRKind) {
		err = KLGetKeyboardLayoutProperty( currentLayout, kKLuchrData, (const void **)&uchrData );
		if (err !=  noErr) return nil;
	} else {
		return nil;
	}
	
	UniCharCount maxStringLength = 4, actualStringLength;
	UniChar unicodeString[4];
	short keyCode = 500;
	err = UCKeyTranslate( uchrData, keyCode, kUCKeyActionDisplay, 0, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, unicodeString );
	return [NSString stringWithCharacters:unicodeString length:1];
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
