//
//  WCAISprite.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCAISprite.h"
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCAISprite

@synthesize entryEffect;
@synthesize state;
@synthesize worldRect;
@synthesize speed;

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	NSAssert(0,@"WCAisprite sub-classes MUST implement isA themselves");
	return -1;
}

/*---------------------------------------------------------------------------*/
- (NSRect)colRect
{
	CGFloat sx = fabs(self.scale.x);
	CGFloat sy = fabs(self.scale.y);
	NSRect aRect = NSMakeRect(worldRect.origin.x - (self.pivot.x * sx), worldRect.origin.y - (self.pivot.y * sy), worldRect.size.width * sx, worldRect.size.height * sy);
	return aRect;
}

/*---------------------------------------------------------------------------*/
- (NSPoint)worldPosition
{
	return worldRect.origin;
}

/*---------------------------------------------------------------------------*/
- (void)setWorldPosition:(NSPoint)aPoint
{
	CGFloat drawPointX = WCGlobals.globalsManager.drawPoint.x;
	CGFloat fw = WCGlobals.globalsManager.fieldSize.width;

	if(aPoint.x < 0.0)
		aPoint.x += fw;
	else if(aPoint.x >= fw)
		aPoint.x -= fw;
	
	worldRect.origin = aPoint;

	aPoint.x -= drawPointX;
	if(aPoint.x < 0.0)
		aPoint.x += fw;
	else if(aPoint.x >= fw)
		aPoint.x -= fw;

	self.position = aPoint;
}

/*---------------------------------------------------------------------------*/
- (void)addCargo:(WCAISprite*)cargo
{
	NSAssert(0,@"WCAisprite sub-classes MUST implement addCargo themselves");
}

/*---------------------------------------------------------------------------*/
- (void)removeCargo:(WCAISprite*)cargo
{
	NSAssert(0,@"WCAisprite sub-classes MUST implement removeCargo themselves");
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSAssert(0,@"WCAisprite sub-classes MUST implement run themselves");
}

@end
