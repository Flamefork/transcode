//
//  AppDelegate.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "AppDelegate.h"
#import "Transcoder.h"
#import "KeyDiscriminant.h"

OSStatus hotkeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	Transcoder *transcoder = (Transcoder *)userData;
	
	NSString *s;
	AXUIElementRef application;
	AXUIElementRef uiElement;
	
	AXUIElementCopyAttributeValue(AXUIElementCreateSystemWide(), kAXFocusedApplicationAttribute, (CFTypeRef *)&application);
	NSLog(@"1");
	if (application) {
		NSLog(@"2");
		AXUIElementCopyAttributeValue(application, kAXFocusedUIElementAttribute, (CFTypeRef *)&uiElement);
		if (uiElement) {
			NSLog(@"3");
			AXUIElementCopyAttributeValue(uiElement, kAXSelectedTextAttribute, (CFTypeRef *)&s);
		} else {
			NSLog(@"4");
			AXUIElementCopyAttributeValue(application, kAXFocusedWindowAttribute, (CFTypeRef *)&uiElement);
			if (uiElement) {
				NSLog(@"5");
				AXUIElementCopyAttributeValue(uiElement, kAXFocusedUIElementAttribute, (CFTypeRef *)&uiElement);
				if (uiElement) {
					NSLog(@"6");
					//AXUIElementCopyAttributeValue(uiElement, kAXSelectedTextAttribute, (CFTypeRef *)&s);
					AXUIElementCopyAttributeValue(uiElement, kAXRoleAttribute, (CFTypeRef *)&s);
				}
			}
		}
	}
	NSLog(s);
	
	NSArray *keyDiscriminants;
	if (s) {
		keyDiscriminants = [transcoder transcode:s];
	}
	
	[transcoder switchLayout];
	
	if (s) {
		KeyDiscriminant *kd;
		for (kd in keyDiscriminants) {
			[kd sendToApplication:application];
		}
	}
	
	return noErr;
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	Transcoder *transcoder;
	transcoder = [[Transcoder alloc] init];
	[transcoder createLayouts];
	
	EventTypeSpec eventType;
	eventType.eventClass = kEventClassKeyboard;
	eventType.eventKind = kEventHotKeyPressed;
	
	EventHotKeyID hotkeyId;
	hotkeyId.signature = 'htk1';
	hotkeyId.id = 1;
	EventHotKeyRef hotkeyRef;
	
	EventHandlerUPP handlerUPP;
	handlerUPP = NewEventHandlerUPP(&hotkeyHandler);
	
	InstallApplicationEventHandler(handlerUPP, 1, &eventType, (void *)transcoder, NULL);
	RegisterEventHotKey(49, cmdKey, hotkeyId, GetApplicationEventTarget(), 0, &hotkeyRef);
}

@end
