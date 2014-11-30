//
//  WCPod.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-25.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCPod.h"
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCPod

@synthesize frame;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		NSPoint speed = NSMakePoint((arc4random_uniform(30) - 15.0) / 10.0, (arc4random_uniform(30) - 15.0) / 10.0);
		speed.x += speed.x > 0 ? 1.0 : -1.0;
		self.speed = speed;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (UInt32)isA
{
	return DB_POD;
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSSize fieldSize = WCGlobals.globalsManager.fieldSize;
	CGFloat selfHeight = self.srcRect.size.height;
	NSPoint worldPoint = self.worldPosition;
	NSPoint speed = self.speed;

	if(!(frameCounter % 3))
	{
		if(++frame >= self.currAnim.numFrames)
			frame = 0;
		
		[self setFrameInCurrAnim:frame];
	}

	worldPoint.x += speed.x;
	worldPoint.y += speed.y;
	
	if(worldPoint.y > fieldSize.height - selfHeight)
		worldPoint.y = selfHeight;
	else if(worldPoint.y < selfHeight)
		worldPoint.y = fieldSize.height - selfHeight;
	
	self.worldPosition = worldPoint;
}

@end
