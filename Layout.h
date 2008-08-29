//
//  Layout.h
//  Transcode
//
//  Created by flamefork on 26.08.08.
//  Copyright 2008 Flamefork. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "KeyDiscriminant.h"

@class KeyDiscriminant;

@interface Layout : NSObject
{
@public
	NSString *layoutID;
@private
	NSMutableDictionary *descData;
	UCKeyboardLayout *ucharData;
}

- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;

- (id)initWithUchrData:(UCKeyboardLayout *) uchrData lid:(NSString *)lid;
- (KeyDiscriminant *)discriminantForChar:(NSString *) uchar;
- (NSString *)charForDiscriminant:(KeyDiscriminant *) discriminant;

@end
