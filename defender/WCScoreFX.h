//
//  WCScoreFX.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCEffects.h"
#import "WCTextout.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCScoreFX : WCEffect

@property (nonatomic, copy)		NSString	*scoreString;
@property						NSPoint		position;
@property						WCTextAttr	*stringAttribs;
@property						UInt32		strLen;
@property						UInt32		tickCounter;
@property						UInt32		yellowIdx;
@property						BOOL		scoreYellowStyle;

- (id)initAt:(NSPoint)aPoint withTimeToLive:(UInt32)ttl andScore:(UInt32)aScore;
- (void)fadeEffect;
- (void)animateAndDrawEffect:(UInt32)frameCounter;

@end
