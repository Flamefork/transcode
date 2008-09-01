//
//  KeyDiscriminant.h
//  Transcode
//
//  Created by flamefork on 29.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KeyDiscriminant : NSObject
{
@public
	UInt16 virtualKeyCode;
	UInt32 modifierKeyState;
}

- (void)sendToApplication:(AXUIElementRef)application;

@end
