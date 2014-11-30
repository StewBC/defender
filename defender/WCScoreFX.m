//
//  WCScoreFX.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCScoreFX.h"
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*/
#define SCOREFX_FADE_TIME_IN_TTL	0.6
#define SCOREFX_FADE_RANGE			(1.0-0.1)
#define SCOREFX_FONT_SCALE			2.0
#define SCOREFX_ANIMATE_SPEED		1

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCScoreFX

@synthesize scoreString;
@synthesize position;
@synthesize stringAttribs;
@synthesize strLen;
@synthesize tickCounter;
@synthesize yellowIdx;
@synthesize scoreYellowStyle;

/*---------------------------------------------------------------------------*/
- (id)initAt:(NSPoint)aPoint withTimeToLive:(UInt32)ttl andScore:(UInt32)aScore
{
	if(self = [super initWithTimeToLive:ttl])
	{
		position = aPoint;
		
		self.timeToFade = SCOREFX_FADE_TIME_IN_TTL * ttl;
		self.fadeAmount = SCOREFX_FADE_RANGE / self.timeToFade;
		
		scoreString = [NSString stringWithFormat:@"%d",aScore];
		
		strLen = (UInt32)[scoreString length];
		stringAttribs = malloc(sizeof(WCTextAttr)*strLen);
		
		if(GAME_SCORE_SAVE_HUMAN == aScore)
			scoreYellowStyle = YES;
		else
			scoreYellowStyle = NO;
		
		if(stringAttribs)
		{
			for(UInt32 i = 0; i < strLen; ++i)
			{
				stringAttribs[i].font = WCCOLOR_BLUE;
				stringAttribs[i].scale = SCOREFX_FONT_SCALE;
				stringAttribs[i].transparency = 1.0;
			}
		}
		
		tickCounter = SCOREFX_ANIMATE_SPEED;
	}
	return self;
}

/*---------------------------------------------------------------------------*/
- (void)fadeEffect
{
	for(UInt32 i = 0; i < strLen; ++i)
	{
		stringAttribs[i].transparency -= self.fadeAmount;
	}
}

/*---------------------------------------------------------------------------*/
- (void)animateAndDrawEffect:(UInt32)frameCounter
{
	if(!tickCounter-- && stringAttribs)
	{
		if(scoreYellowStyle)
		{
			if(yellowIdx)
				stringAttribs[yellowIdx].font = WCCOLOR_BLUE;
			else
				stringAttribs[yellowIdx].font = WCCOLOR_RED;
			
			if(++yellowIdx == strLen)
				yellowIdx = 0;
			
			stringAttribs[yellowIdx].font = WCCOLOR_YELLOW;
		}
		else
		{
			UInt32 font = stringAttribs[0].font;
			if(++font > WCCOLOR_NUM_COLORS)
				font = 0;
			for(UInt32 i = 0; i < strLen; ++i)
			{
				stringAttribs[i].font = font;
			}
		}
		tickCounter = SCOREFX_ANIMATE_SPEED;
	}
	
	NSPoint worldDelta = WCGlobals.globalsManager.drawPoint;
	worldDelta.x -= self.worldPoint.x;
	CGFloat fw = WCGlobals.globalsManager.fieldSize.width;
	self.worldPoint = WCGlobals.globalsManager.drawPoint;

	position.x -= worldDelta.x;
	if(position.x < 0.0)
		position.x += fw;
	else if(position.x > fw)
		position.x -= fw;

	// Using attribs - font and scale parameters ignored
	[WCTextout printAtX:position.x atY:position.y theString:scoreString atScale:0.0 inFont:0 orAttribs:stringAttribs];
}

/*---------------------------------------------------------------------------*/
- (void)dealloc
{
	if(stringAttribs)
		free(stringAttribs);
}

@end
