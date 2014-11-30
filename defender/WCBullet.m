//
//  WCBullet.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-11.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCBullet.h"
#import "WCGlobals.h"
#import "WCAIs.h"

/*---------------------------------------------------------------------------*/
#define	BULLET_TRAVEL_TIME		GAME_SECONDS(1.25)
#define BULLET_ALIVE_TRAVEL		640

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCBullet

@synthesize speed;
@synthesize travelDistance;

/*---------------------------------------------------------------------------*/
+ (WCBullet*)makeBulletAt:(NSPoint)aPoint aimingAt:(NSPoint)bPoint withVelocity:(CGFloat)velocity
{
	WCBullet *aBullet = [WCSpriteManager makeSpriteClass:[WCBullet class] fromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_BULLET]];
	CGFloat left, right, dx;
	
	if(aPoint.x > bPoint.x)
	{
		left = aPoint.x - bPoint.x;
		right = (WCGlobals.globalsManager.fieldSize.width + bPoint.x) - aPoint.x;
	}
	else
	{
		left = (WCGlobals.globalsManager.fieldSize.width + aPoint.x) - bPoint.x;
		right = bPoint.x - aPoint.x;
	}
	
	if(left <= right)
		dx = -left;
	else
		dx = right;
	
	NSPoint delta = NSMakePoint(dx, bPoint.y - aPoint.y);
	delta.x += velocity * BULLET_TRAVEL_TIME;

	aBullet.speed = NSMakePoint(delta.x / BULLET_TRAVEL_TIME, delta.y / BULLET_TRAVEL_TIME);
	aBullet.worldRect = NSMakeRect(aPoint.x, aPoint.y, aBullet.srcRect.size.width, aBullet.srcRect.size.height);
	aBullet.scale = NSMakePoint(SPRITE_SCALE, SPRITE_SCALE);
	aBullet.travelDistance = 0;
	
	[WCGlobals.globalsManager.theAIs.fixupList addObject:aBullet];
	
	return aBullet;
}

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_BULLET;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSPoint worldPoint = self.worldPosition;
	CGFloat viewHeight = WCGlobals.globalsManager.fieldSize.height;
	
	worldPoint.x += speed.x;
	worldPoint.y += speed.y;
	travelDistance += sqrt(speed.x * speed.x + speed.y * speed.y);

	if(worldPoint.y <= 0.0 || worldPoint.y >= viewHeight || travelDistance > BULLET_ALIVE_TRAVEL)
		self.dead = YES;

	self.worldPosition = worldPoint;
}

@end
