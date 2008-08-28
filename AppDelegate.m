//
//  AppDelegate.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "AppDelegate.h"
#import "Transcoder.h"

OSStatus hotkeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	Transcoder *transcoder = (Transcoder *)userData;
	
	NSString *s;
	AXUIElementRef application;
	AXUIElementRef uiElement;
	
	AXUIElementCopyAttributeValue(AXUIElementCreateSystemWide(), kAXFocusedApplicationAttribute, (CFTypeRef *)&application);
	if (!application) return noErr;
	
	AXUIElementCopyAttributeValue(application, kAXFocusedUIElementAttribute, (CFTypeRef *)&uiElement);
	if (!uiElement) return noErr;
	
	AXUIElementCopyAttributeValue(uiElement, kAXRoleAttribute, (CFTypeRef *)&s);
	NSLog(@"kAXRoleAttribute = %s", [s UTF8String]);
	
	AXUIElementCopyAttributeValue(uiElement, kAXSelectedTextAttribute, (CFTypeRef *)&s);
	NSLog(@"kAXSelectedTextAttribute = %s", [s UTF8String]);
	
	AXUIElementSetAttributeValue(uiElement, kAXSelectedTextAttribute, (CFTypeRef)[transcoder transcode:s]);
	
//	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )56, true);
//	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )6, true);
//	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )6, false);
//	AXUIElementPostKeyboardEvent(application, 0, (CGKeyCode )56, false);
	
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
