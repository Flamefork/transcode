//
//  Layout.m
//  Transcode
//
//  Created by flamefork on 26.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "Layout.h"

@implementation Layout

- (BOOL)isEqual:(id)anObject
{
	// Dirty hack for search
	if ([anObject isKindOfClass:[NSString class]]) {
		return [layoutID isEqual:anObject];
	}
	// Common
	if ([anObject isKindOfClass:[Layout class]]) {
		Layout *lay = (Layout *)anObject;
		return [layoutID isEqual:lay->layoutID];
	}
	return NO;
}
- (NSUInteger)hash
{
	return [layoutID hash];
}

- (id)initWithUchrData:(UCKeyboardLayout *) uchrData lid:(NSString *)lid
{
	layoutID = lid;
	[layoutID retain];
	
	descData = [NSMutableDictionary dictionary];
	[descData retain];
	
	ucharData = uchrData;
	
	static UInt32 modifierKeyStates[] = {0, shiftKey, /*optionKey, controlKey, optionKey | shiftKey*/};
	
    int i;
	for (i = 0; i < (sizeof(modifierKeyStates) / sizeof(UInt32)); i++) {
		UInt16 keyCode;
		for (keyCode = 0; keyCode < 128; keyCode++) {
			KeyDiscriminant *discriminant = [[KeyDiscriminant alloc] init];
			discriminant->modifierKeyState = modifierKeyStates[i];
			discriminant->virtualKeyCode = keyCode;
			
			NSString *uchar = [self charForDiscriminant:discriminant];
			
			if (![descData objectForKey:uchar]) {
				[descData setObject: discriminant forKey:uchar];
			}
		}
	}
	
	return self;
}
- (KeyDiscriminant *)discriminantForChar:(NSString *) uchar
{
	return [descData objectForKey:uchar];
}
- (NSString *)charForDiscriminant:(KeyDiscriminant *) discriminant
{
	UniCharCount maxStringLength = 4, actualStringLength;
	UniChar unicodeString[4];
	UInt32 deadKeyState;
	
	UCKeyTranslate(ucharData, discriminant->virtualKeyCode, kUCKeyActionDisplay, (discriminant->modifierKeyState >> 8) & 0xFF, LMGetKbdType(), kUCKeyTranslateNoDeadKeysBit, &deadKeyState, maxStringLength, &actualStringLength, unicodeString);
	return [NSString stringWithCharacters:unicodeString length:actualStringLength];
}

@end
