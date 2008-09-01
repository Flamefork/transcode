//
//  AppDelegate.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "AppDelegate.h"
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
		keyDiscriminants = [transcoder decode:s];
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
	transcoder = [[Transcoder alloc] init];
	[transcoder retain];
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
	
	[NSApp setServicesProvider:self];
	NSUpdateDynamicServices();
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
	
	NSArray *decoded = [transcoder decode:pboardString];
	
	[transcoder switchLayout];
	newString = [transcoder encode:decoded];
	
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
