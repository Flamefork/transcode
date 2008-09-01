//
//  AppDelegate.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "AppDelegate.h"
#import "KeyDiscriminant.h"

AXUIElementRef AXUIElementGetChild(AXUIElementRef element, NSUInteger atIndex, bool notEmpty, NSString *withTitle)
{
	NSArray *children;
	AXUIElementCopyAttributeValue(element, kAXChildrenAttribute, (CFTypeRef *)&children);
	
	if (!children) return NULL;
	
	NSUInteger i, count = [children count];
	
	if (!count) return NULL;
	
	if (!notEmpty && !withTitle) {
		return (AXUIElementRef)[children objectAtIndex:atIndex];
	}
	
	for (i = 0; i < count; i++) {
		AXUIElementRef result = (AXUIElementRef)[children objectAtIndex:i];
		if (notEmpty) {
			NSArray *subchildren;
			AXUIElementCopyAttributeValue(result, kAXChildrenAttribute, (CFTypeRef *)&subchildren);
			if (!subchildren || ![subchildren count]) continue;
		}
		if (withTitle) {
			NSString *s;
			AXUIElementCopyAttributeValue(result, kAXTitleAttribute, (CFTypeRef *)&s);
			if (!s || ![s isEqualToString:withTitle]) continue;
		}
		return result;
	}
	
	return NULL;
}

bool useService(AXUIElementRef application, Transcoder *transcoder) {
	AXUIElementRef uiElement;
	
	AXUIElementCopyAttributeValue(application, kAXMenuBarAttribute, (CFTypeRef *)&uiElement); // Menu bar
	if (!uiElement) return FALSE;
	
	uiElement = AXUIElementGetChild(uiElement, 1, FALSE, nil); // Application menu bar item
	if (!uiElement) return FALSE;
	
	uiElement = AXUIElementGetChild(uiElement, 0, FALSE, nil); // Application menu
	if (!uiElement) return FALSE;
	
	uiElement = AXUIElementGetChild(uiElement, 0, TRUE, nil); // Services menu item
	if (!uiElement) return FALSE;
	
	uiElement = AXUIElementGetChild(uiElement, 0, FALSE, nil); // Services menu
	if (!uiElement) return FALSE;
	
	uiElement = AXUIElementGetChild(uiElement, 0, FALSE, @"Transcode"); // Transcode menu item
	if (!uiElement) return FALSE;
	
	AXUIElementPerformAction(uiElement, kAXPressAction); // At last!!!
	
	return TRUE;
}

bool useKeyboardEvents(AXUIElementRef application, Transcoder *transcoder) {
	AXUIElementRef uiElement;
	NSString *s;
	
	AXUIElementCopyAttributeValue(application, kAXFocusedUIElementAttribute, (CFTypeRef *)&uiElement);
	if (!uiElement) return FALSE;
	
	AXUIElementCopyAttributeValue(uiElement, kAXSelectedTextAttribute, (CFTypeRef *)&s);
	if (!s) return FALSE;
	
	NSArray *keyDiscriminants;
	keyDiscriminants = [transcoder decode:s];
	
	[transcoder switchLayout];
	
	KeyDiscriminant *kd;
	for (kd in keyDiscriminants) {
		[kd sendToApplication:application];
	}
	
	return TRUE;
}


OSStatus hotkeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	Transcoder *transcoder = (Transcoder *)userData;
	
	AXUIElementRef application;
	
	AXUIElementCopyAttributeValue(AXUIElementCreateSystemWide(), kAXFocusedApplicationAttribute, (CFTypeRef *)&application);
	if (application) {
		if(useService(application, transcoder)) {
			return noErr;
		}
		
		if (useKeyboardEvents(application, transcoder)) {
			return noErr;
		}
	}
	// If nothing helps - just switch this f***ing layout
	[transcoder switchLayout];
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
