//
//  Layout.h
//  Transcode
//
//  Created by flamefork on 26.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@class KeyDiscriminant;

@interface Layout : NSObject
{
	NSMutableDictionary *descData;
	UCKeyboardLayout *ucharData;
}

+ (NSDictionary *) createLayouts;
- (id)initWithUchrData:(UCKeyboardLayout *) uchrData;
- (KeyDiscriminant *)discriminantForChar:(NSString *) uchar;
- (NSString *)charForDiscriminant:(KeyDiscriminant *) discriminant;

@end

@interface KeyDiscriminant : NSObject
{
@public
	UInt16 virtualKeyCode;
	UInt32 modifierKeyState;
}
@end
