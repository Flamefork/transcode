//
//  AppDelegate.h
//  Transcode
//
//  Created by flamefork on 22.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import "Transcoder.h"

@interface AppDelegate : NSObject
{
@public
	Transcoder *transcoder;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

@end
