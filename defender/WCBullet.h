//
//  WCBullet.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-11.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCBullet : WCAISprite

@property		NSPoint	speed;
@property		UInt32	travelDistance;

+ (WCBullet*)makeBulletAt:(NSPoint)aPoint aimingAt:(NSPoint)bPoint withVelocity:(CGFloat)velocity;
- (UInt32)isA;
- (void)run:(UInt32)frameCounter;

@end
