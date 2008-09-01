//
//  KeyDiscriminant.m
//  Transcode
//
//  Created by flamefork on 29.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "KeyDiscriminant.h"

@implementation KeyDiscriminant

- (void)sendToApplication:(AXUIElementRef)application
{
	if (self->modifierKeyState & shiftKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )56, true);
	}
	
	if (self->modifierKeyState & controlKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )59, true);
	}
	
	if (self->modifierKeyState & optionKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )58, true);
	}
	
	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )self->virtualKeyCode, true);
	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )self->virtualKeyCode, false);
	
	if (self->modifierKeyState & optionKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )58, false);
	}
	
	if (self->modifierKeyState & controlKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )59, false);
	}
	
	if (self->modifierKeyState & shiftKey) {
		AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )56, false);
	}
}

@end
