//
//  WCTextFX.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-20.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCTextFX.h"
#import "WCGlobals.h"

/*---------------------------------------------------------------------------*/
#define SCOREFX_FADE_TIME_IN_TTL	0.5
#define SCOREFX_FADE_RANGE			(1.0-0.0)
#define SCOREFX_FONT_SCALE			2.0
#define SCOREFX_ANIMATE_SPEED		1

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCTextFX

@synthesize scoreString;
@synthesize position;
@synthesize stringAttribs;
@synthesize strLen;

/*---------------------------------------------------------------------------*/
- (id)initAt:(NSPoint)aPoint withTimeToLive:(UInt32)ttl string:(NSString*)aString andAttribs:(WCTextAttr*)aAttribs
{
	if(self = [super initWithTimeToLive:ttl])
	{
		position = aPoint;
		
		self.timeToFade = SCOREFX_FADE_TIME_IN_TTL * ttl;
		self.fadeAmount = SCOREFX_FADE_RANGE / self.timeToFade;
		
		scoreString = aString;
		
		strLen = (UInt32)[scoreString length];
		stringAttribs = malloc(sizeof(WCTextAttr)*strLen);
		if(aAttribs)
		{
			memcpy(stringAttribs, aAttribs, strLen);
		}
		else
		{
			for(int i=0; i < strLen; ++i)
			{
				stringAttribs[i].font = WCCOLOR_YELLOW;
				stringAttribs[i].scale = SPRITE_SCALE;
				stringAttribs[i].transparency = 1.0;
			}
		}
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
	// Using attribs - ignore scale and font parameters
	[WCTextout printAtX:position.x atY:position.y theString:scoreString atScale:0 inFont:0 orAttribs:stringAttribs];
}

/*---------------------------------------------------------------------------*/
- (void)dealloc
{
	if(stringAttribs)
		free(stringAttribs);
}

@end
