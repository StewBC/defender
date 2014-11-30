//
//  WCEffects.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCEffects.h"
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCParticleSprite

@synthesize speed;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCEffect

@synthesize timeToLive;
@synthesize timeToFade;
@synthesize fadeAmount;
@synthesize worldPoint;

/*---------------------------------------------------------------------------*/
- (id)initWithTimeToLive:(UInt32)ttl
{
	if(self = [super init])
	{
		self.timeToLive = self.timeToFade = ttl;
		self.worldPoint = WCGlobals.globalsManager.drawPoint;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)fadeEffect
{
	NSLog(@"effect should provide fadeEffect");
}

/*---------------------------------------------------------------------------*/
- (void)animateAndDrawEffect:(UInt32)frameCounter
{
	NSLog(@"effect should provide animateEffect");
}

/*---------------------------------------------------------------------------*/
- (BOOL)run:(UInt32)frameCounter
{
	if(timeToFade)
		--timeToFade;
	else
		[self fadeEffect];
	
	[self animateAndDrawEffect:frameCounter];
	
	if(!timeToLive--)
		return NO;
	
	return YES;
}

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCEffects

@synthesize	effectsList;

- (id)init
{
	if(self = [super init])
	{
		effectsList = [NSMutableArray new];
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)removeAllEffects
{
	[effectsList removeAllObjects];
}


/*---------------------------------------------------------------------------*/
- (void)addEffect:(WCEffect*)anEffect
{
	[effectsList addObject:anEffect];
}

/*---------------------------------------------------------------------------*/
- (void)run:(UInt32)frameCounter
{
	NSMutableArray *deadEffects = [NSMutableArray array];

	for(WCEffect *anEffect in effectsList)
	{
		if(![anEffect run:frameCounter])
		{
			[deadEffects addObject:anEffect];
		}
	}
	
	for(WCEffect *anEffect in deadEffects)
	{
		[effectsList removeObject:anEffect];
	}
	
	[deadEffects removeAllObjects];
}
@end
