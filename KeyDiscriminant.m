//
//  KeyDiscriminant.m
//  Transcode
//
//  Created by flamefork on 29.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeyDiscriminant.h"

@implementation KeyDiscriminant

- (void)sendToApplication:(AXUIElementRef)application
{
	//	key code  54 = [Command]
	//	key code  56 = [Shift]
	
	if (self->modifierKeyState == shiftKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )56, true);
	}
	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )self->virtualKeyCode, true);
	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )self->virtualKeyCode, false);
	
	if (self->modifierKeyState == shiftKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )56, false);
	}
	
}

@end
