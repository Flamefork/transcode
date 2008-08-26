//
//  Layout.m
//  Transcode
//
//  Created by flamefork on 26.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Layout.h"

@implementation Layout

+ (NSDictionary *) createLayouts
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
		
		Layout *layout = [[Layout alloc] initWithUchrData:uchrData];
		
		[result setObject:layout forKey:isid];
	}
	
	return result;
}
- (id)initWithUchrData:(UCKeyboardLayout *) uchrData
{
	ucharData = uchrData;
	descData = [NSMutableDictionary dictionary];
	
	static UInt32 modifierKeyStates[] = {0, shiftKey, optionKey, controlKey, optionKey | shiftKey};
	
    int i;
	for (i = 0; i < (sizeof(modifierKeyStates) / sizeof(UInt32)); i++) {
		KeyDiscriminant *discriminant = [[KeyDiscriminant alloc] init];
		discriminant->modifierKeyState = modifierKeyStates[i];
		
		UInt16 keyCode;
		for (keyCode = 0; keyCode < 127; keyCode++) {
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

@implementation KeyDiscriminant
@end
