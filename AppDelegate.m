//
//  AppDelegate.m
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "AppDelegate.h"
#import "Transcoder.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	Transcoder *transcoder; 
	transcoder = [[Transcoder alloc] init]; 
	[NSApp setServicesProvider:transcoder];
	
	NSUpdateDynamicServices();
}

@end
