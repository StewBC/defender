//
//  WCTextFX.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-20.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCEffects.h"
#import "WCTextout.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCTextFX : WCEffect

@property (nonatomic, copy)		NSString	*scoreString;
@property						WCTextAttr	*stringAttribs;
@property						NSPoint		position;
@property						UInt32		strLen;

- (id)initAt:(NSPoint)aPoint withTimeToLive:(UInt32)ttl string:(NSString*)aString andAttribs:(WCTextAttr*)aAttribs;
- (void)fadeEffect;
- (void)animateAndDrawEffect:(UInt32)frameCounter;

@end
