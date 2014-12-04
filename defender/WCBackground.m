//
//  WCBackground.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCBackground.h"
#import "WCGlobals.h"
#import "WCSoundManager.h"
#import "WCTextout.h"
#import "WCGrndExpFX.h"
#import "WCAIs.h"
#import "WCPlayer.h"

/*---------------------------------------------------------------------------*/
#define STARS_PER_SCREEN					25
#define STARS_SCREENS_PER_FIELD				8
#define STARS_NUM_STARS						(STARS_PER_SCREEN * STARS_SCREENS_PER_FIELD)
#define STARS_STRIPS_PER_SCREEN				16
#define STARS_NUM_STRIPS					(STARS_SCREENS_PER_FIELD * STARS_STRIPS_PER_SCREEN)
#define STARS_NUM_STRIPS_Y					6
#define STARS_HEIGHT_PER_SCREEN				(67.0/80)
#define STARS_COLOR_HUE_INCREMENT			(1.0/6.0)
#define STARS_FLICKER_WINDOW				128
#define STARS_MIN_HOLDTIME					30
#define	BG_GROUND_LINE_THICKNESS			(4.0/STARS_STRIPS_PER_SCREEN)
#define BG_HUD_WIDTH						0.5
#define	BG_HUD_SCORE_FLASH_TIME				6
#define BG_MAP_ICON_SIZE					(8.0*SPRITE_SCALE)
#define BG_MAP_Y_SCALE_INFLATION			2.5

#define BG_RENDER_TARGET_HEIGHT				(160*SPRITE_SCALE)
#define BG_HUD_TEXT_POS						((BG_RENDER_TARGET_HEIGHT*STARS_HEIGHT_PER_SCREEN)+(3*5))

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCBackground

@synthesize colors;
@synthesize groundPoints;
@synthesize stripWidth;
@synthesize numStrips;
@synthesize vitalsFont;
@synthesize scoreFlashTimer;
@synthesize scoreOffFlag;
@synthesize bombTipColor;
@synthesize podFlashTimer;

/*---------------------------------------------------------------------------*/
- (id)init
{
	if(self = [super init])
	{
		WCGlobals.globalsManager.fieldSize = NSMakeSize(WCGlobals.globalsManager.viewSize.width * STARS_SCREENS_PER_FIELD, WCGlobals.globalsManager.viewSize.height * STARS_HEIGHT_PER_SCREEN);

		stars = (WCStar*)malloc(sizeof(WCStar) * STARS_NUM_STARS);
		stripWidth = WCGlobals.globalsManager.fieldSize.width / STARS_NUM_STRIPS;
		stripIndex = (UInt32*)malloc(sizeof(UInt32) * STARS_NUM_STRIPS);
		groundPoints = (NSPoint*)malloc(sizeof(NSPoint)*STARS_NUM_STRIPS);
		numStrips = STARS_NUM_STRIPS;

		colors = [NSMutableArray array];

		CGFloat step = STARS_COLOR_HUE_INCREMENT;
		for(CGFloat hue = 0.0; hue < 1.0; hue += step)
		{
			NSColor *color = [NSColor colorWithHue:hue
										saturation:1.0
										brightness:1.0
											 alpha:1.0];
			[colors addObject:color];
		}
		[colors addObject:[NSColor whiteColor]];
		[colors addObject:[NSColor brownColor]];

		[self makeGround];
		[self makeStars];
	}
	return self;
}

/*---------------------------------------------------------------------------*/
int starCmp(const void *a, const void *b)
{
	WCStar *lhs = (WCStar *)a;
	WCStar *rhs = (WCStar *)b;
	
	if (lhs->frame.origin.x > rhs->frame.origin.x)
		return 1;
	else
		return -1;
}

/*---------------------------------------------------------------------------*/
- (void)makeGround
{
	UInt32 stripHeight = (WCGlobals.globalsManager.fieldSize.height * (1.0-STARS_HEIGHT_PER_SCREEN)) / 2;
	UInt32 lastValue = arc4random_uniform(stripHeight);
	
	groundPoints[0].x = 0;
	groundPoints[0].y = stripHeight + lastValue;
	
	for(int i=1; i < STARS_NUM_STRIPS; ++i)
	{
		int32_t delta = arc4random_uniform(stripHeight*2) - stripHeight;
		groundPoints[i].x = stripWidth * i;
		groundPoints[i].y = stripHeight + ((lastValue + delta)) % (UInt32)(2.5 * stripHeight);
		lastValue = groundPoints[i].y;
	}

	// Create a recognizable ground-feature
	groundPoints[0].y = stripHeight * 5.0;
	groundPoints[1].y = stripHeight * 6.0;
	groundPoints[2].y = stripHeight * 5.0;
}

/*---------------------------------------------------------------------------*/
- (CGFloat)getGroundHeightAtX:(CGFloat)xPos
{
	int32_t gi = xPos / stripWidth;
	if(gi >= numStrips)
		gi = 0;

	NSPoint p0 = groundPoints[gi];
	if(++gi == numStrips)
		gi = 0;

	NSPoint p1 = groundPoints[gi];
	
	CGFloat x = xPos - p0.x;
	return ((p1.y - p0.y)/(p1.x-p0.x))*x + p0.y;
}

/*---------------------------------------------------------------------------*/
- (void)blowupGround
{
	WCGlobals.globalsManager.groundOkay = NO;
	[[WCSoundManager findSound:DB_STRINGS[DB_WORLDEXPLODE]] play];
	WCEffect *effect = [[WCGrndExpFX alloc] initWithTimeToLive:GAME_SECONDS(4.5)];
	[WCGlobals.globalsManager.theEffects addEffect:effect];
}

/*---------------------------------------------------------------------------*/
- (void)makeStars
{
	UInt32 w = WCGlobals.globalsManager.fieldSize.width;
	UInt32 h = WCGlobals.globalsManager.fieldSize.height;
	UInt32 n = (UInt32)[colors count];
	
	for(int i=0; i < STARS_NUM_STARS; ++i)
	{
		int s = arc4random_uniform(2)+2;
		stars[i].frame = NSMakeRect(arc4random_uniform(w), arc4random_uniform(h), s, s);
		stars[i].visible = arc4random_uniform(2);
		stars[i].decay = STARS_MIN_HOLDTIME + arc4random_uniform(STARS_FLICKER_WINDOW);
		stars[i].colorIndex = arc4random_uniform(2);
		stars[i].colors[0] = arc4random_uniform(n);
		stars[i].colors[1] = arc4random_uniform(n);
	}
	
	qsort(stars, STARS_NUM_STARS, sizeof(WCStar), starCmp);
	
	w = 0;
	for(int j=0, i=0; i < STARS_NUM_STARS; ++i)
	{
		if(stars[i].frame.origin.x > w)
		{
			stripIndex[j++] = i;
			w += stripWidth;
		}
	}
}

/*---------------------------------------------------------------------------*/
- (void)drawGround:(UInt32)stripCount atOffset:(NSPoint)drawPoint
{
	if(WCGlobals.globalsManager.groundOkay)
	{
		CGFloat fw = WCGlobals.globalsManager.fieldSize.width;
		UInt32 gi = (UInt32)drawPoint.x / stripWidth;
		NSBezierPath *aPath = [NSBezierPath bezierPath];
		NSPoint aPoint = groundPoints[gi++];

		aPoint.x -= drawPoint.x;
		[aPath moveToPoint:aPoint];
		
		for(int i=0;i<=stripCount;++i)
		{
			if(gi >= STARS_NUM_STRIPS)
			{
				gi = 0;
				drawPoint.x -= fw;
			}
			aPoint = groundPoints[gi++];
			aPoint.x -= drawPoint.x;
			[aPath lineToPoint:aPoint];
		}
		
		[[NSColor brownColor] set];
		[aPath setLineWidth:BG_GROUND_LINE_THICKNESS*stripCount];
		[aPath stroke];
		[aPath removeAllPoints];
	}
}

/*---------------------------------------------------------------------------*/
- (void)showVitals
{
	if(!scoreFlashTimer--)
	{
		scoreFlashTimer = BG_HUD_SCORE_FLASH_TIME;
		
		if(++vitalsFont == WCCOLOR_NUM_COLORS)
			vitalsFont = 0;
	
		if(!WCGlobals.globalsManager.hasScored)
			scoreOffFlag = 1 - scoreOffFlag;
		else
			scoreOffFlag = 0;
	}

	CGFloat yHeight = BG_HUD_TEXT_POS;
	if(1 == WCGlobals.globalsManager.activePlayer || !scoreOffFlag)
	{
		[WCTextout printAtX:12 atY:yHeight theString:[NSString stringWithFormat:@"%8d",[WCGlobals.globalsManager theScore:0]] atScale:SPRITE_SCALE inFont:vitalsFont orAttribs:Nil];
	}

	WCSprite *aShip = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_PLAYER]];
	aShip.scale = NSMakePoint(SPRITE_SCALE*0.66,SPRITE_SCALE*0.66);
	UInt32 lives = [WCGlobals.globalsManager theLives:0];
	if(lives)
	{
		if(!WCGlobals.globalsManager.activePlayer)
			lives -= 1;
		if(lives > 3)
		{
			aShip.position = NSMakePoint(129, yHeight+25);
			[WCSpriteManager renderSprite:aShip onLayer:RENDER_LAYER_TEXT withCopy:YES];
			[WCTextout printAtX:12 atY:yHeight+25 theString:[NSString stringWithFormat:@"%5dX",lives] atScale:SPRITE_SCALE inFont:vitalsFont orAttribs:Nil];
		}
		else
		{
			for(int i = 0; i < lives; ++i)
			{
				aShip.position = NSMakePoint(129-i*(132/3), yHeight+25);
				[WCSpriteManager renderSprite:aShip onLayer:RENDER_LAYER_TEXT withCopy:YES];
			}
		}
	}
	
	WCSprite *aLine = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_COLORS]];
	aLine.scale = NSMakePoint(2*SPRITE_SCALE,SPRITE_SCALE);
	if(++bombTipColor >= 2*WCCOLOR_NUM_COLORS)
		bombTipColor = 0;
	[aLine setFrameInCurrAnim:bombTipColor/2];
	
	WCSprite *anSBomb = [WCSpriteManager makeSpriteFromImage:DB_STRINGS[DB_SPRITES_PNG] forAnim:DB_STRINGS[DB_SMARTBOMB]];
	anSBomb.scale = NSMakePoint(SPRITE_SCALE,SPRITE_SCALE);
	UInt32 numBombs = [WCGlobals.globalsManager theSmartBombs:0];
	if(numBombs)
	{
		if(numBombs > 6)
		{
			anSBomb.position = NSMakePoint(162, yHeight+54);
			[WCSpriteManager renderSprite:anSBomb onLayer:RENDER_LAYER_TEXT withCopy:YES];
			aLine.position = NSMakePoint(171, yHeight+54);
			[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
			[WCTextout printAtX:18 atY:yHeight+54 theString:[NSString stringWithFormat:@"%7dX",numBombs] atScale:SPRITE_SCALE inFont:vitalsFont orAttribs:Nil];
		}
		else
		{
			for(int i = 0; i < numBombs; ++i)
			{
				anSBomb.position = NSMakePoint(162, yHeight-3+i*12);
				[WCSpriteManager renderSprite:anSBomb onLayer:RENDER_LAYER_TEXT withCopy:YES];
				aLine.position = NSMakePoint(171, yHeight-3+i*12);
				[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
			}
		}
	}
	
	if(WCGlobals.globalsManager.numActivePlayers > 1)
	{
		if(0 == WCGlobals.globalsManager.activePlayer || !scoreOffFlag)
		{
			[WCTextout printAtX:WCGlobals.globalsManager.viewSize.width-138 atY:yHeight theString:[NSString stringWithFormat:@"%d",[WCGlobals.globalsManager theScore:1]] atScale:SPRITE_SCALE inFont:vitalsFont orAttribs:Nil];
		}

		lives = [WCGlobals.globalsManager theLives:1];
		if(lives)
		{
			if(1 == WCGlobals.globalsManager.activePlayer)
				lives -= 1;
			if(lives > 3)
			{
				aShip.position = NSMakePoint(WCGlobals.globalsManager.viewSize.width - 129, yHeight+25);
				[WCSpriteManager renderSprite:aShip onLayer:RENDER_LAYER_TEXT withCopy:YES];
				[WCTextout printAtX:WCGlobals.globalsManager.viewSize.width - 102 atY:yHeight+25 theString:[NSString stringWithFormat:@"X%d",lives] atScale:SPRITE_SCALE inFont:vitalsFont orAttribs:Nil];
			}
			else
			{
				for(int i = 0; i < lives; ++i)
				{
					aShip.position = NSMakePoint(WCGlobals.globalsManager.viewSize.width - 129+i*(132/3), yHeight+25);
					[WCSpriteManager renderSprite:aShip onLayer:RENDER_LAYER_TEXT withCopy:YES];
				}
			}
		}
		
		numBombs = [WCGlobals.globalsManager theSmartBombs:1];
		anSBomb.scale = NSMakePoint(-SPRITE_SCALE,SPRITE_SCALE);
		if(numBombs)
		{
			if(numBombs > 6)
			{
				anSBomb.position = NSMakePoint(WCGlobals.globalsManager.viewSize.width - 162, yHeight+54);
				[WCSpriteManager renderSprite:anSBomb onLayer:RENDER_LAYER_TEXT withCopy:YES];
				aLine.position = NSMakePoint(WCGlobals.globalsManager.viewSize.width - 171, yHeight+54);
				[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
				[WCTextout printAtX:WCGlobals.globalsManager.viewSize.width - 144 atY:yHeight+54 theString:[NSString stringWithFormat:@"X%d",numBombs] atScale:SPRITE_SCALE inFont:vitalsFont orAttribs:Nil];
			}
			else
			{
				for(int i = 0; i < numBombs; ++i)
				{
					anSBomb.position = NSMakePoint(WCGlobals.globalsManager.viewSize.width - 162, yHeight-3+i*12);
					[WCSpriteManager renderSprite:anSBomb onLayer:RENDER_LAYER_TEXT withCopy:YES];
					aLine.position = NSMakePoint(WCGlobals.globalsManager.viewSize.width - 171, yHeight-3+i*12);
					[WCSpriteManager renderSprite:aLine onLayer:RENDER_LAYER_TEXT withCopy:YES];
				}
			}
		}
	}
}

/*---------------------------------------------------------------------------*/
- (void)drawMinMap
{
	NSBezierPath *aPath = [NSBezierPath bezierPath];
	NSSize viewSize = WCGlobals.globalsManager.viewSize;
	NSSize fieldSize = WCGlobals.globalsManager.fieldSize;
	NSPoint aPoint = NSMakePoint(0, fieldSize.height);
	CGFloat hvw = viewSize.width/2.0;
	CGFloat hfw = fieldSize.width/2.0;
	NSRect aRect = NSMakeRect(
							  (viewSize.width - (viewSize.width * BG_HUD_WIDTH))/2.0,
							  fieldSize.height,
							  (viewSize.width * BG_HUD_WIDTH),
							  viewSize.height-fieldSize.height-SPRITE_SCALE);
	
	// Draw the base line
	[aPath moveToPoint:aPoint];
	aPoint.x = aRect.origin.x;
	[aPath lineToPoint:aPoint];
	aPoint.x += aRect.size.width;
	[aPath moveToPoint:aPoint];
	aPoint.x = viewSize.width;
	[aPath lineToPoint:aPoint];
	
	[NSBezierPath setDefaultLineWidth:SPRITE_SCALE];
	[(NSColor*)[colors objectAtIndex:WCGlobals.globalsManager.aiLevel % WCCOLOR_NUM_COLORS] set];
	[aPath stroke];
	[aPath removeAllPoints];
	
	// draw the mini-map box
	[NSBezierPath strokeRect:aRect];

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//	NSRect viewRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
//	viewRect.size = viewSize;
//	[[NSColor yellowColor] set];
//	for(WCAISprite *anAi in WCGlobals.globalsManager.theAIs.aiList)
//	{
//		NSRect wr = anAi.colRect;
//		wr.origin.x -= WCGlobals.globalsManager.drawPoint.x;
//		if(wr.origin.x < 0.0)
//			wr.origin.x += fieldSize.width;
//		
//		[NSBezierPath fillRect:wr];
//	}
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

	// Save state & set clipping to mini-map area
	[NSGraphicsContext saveGraphicsState];
	[NSBezierPath clipRect:aRect];

	// Get the left most point of the world
	NSPoint drawPoint = NSMakePoint(WCGlobals.globalsManager.drawPoint.x+hvw - hfw, 0.0);
	if(drawPoint.x < 0.0)
		drawPoint.x += fieldSize.width;
	
	// Scale down to draw the mini map and translate to where it will be
	NSAffineTransform *xform = [NSAffineTransform transform];
	CGFloat scale = aRect.size.width/WCGlobals.globalsManager.fieldSize.width;
	[xform translateXBy:(viewSize.width - (viewSize.width * BG_HUD_WIDTH))/2.0 yBy:fieldSize.height+SPRITE_SCALE];
	[xform scaleXBy:scale yBy:scale*BG_MAP_Y_SCALE_INFLATION];
	[xform concat];

	// Draw ground in mini-map
	[self drawGround:STARS_NUM_STRIPS atOffset:drawPoint];

	// Draw all the AIs in the mini map
	aRect = NSMakeRect(0.0, 0.0, BG_MAP_ICON_SIZE*BG_MAP_Y_SCALE_INFLATION, BG_MAP_ICON_SIZE);
	for(WCAISprite *anAi in WCGlobals.globalsManager.theAIs.aiList)
	{
		switch([anAi isA])
		{
			case DB_PLAYER:	// Only in Demo mode - fake player
				[[NSColor whiteColor] set];
				break;
				
			case DB_LANDER:
			case DB_BAITER:
				[[NSColor greenColor] set];
				break;
				
			case DB_MUTANT:
				[(NSColor*)[colors objectAtIndex:arc4random_uniform((UInt32)[colors count])] set];
				break;
				
			case DB_BOMBER:
				[[NSColor blueColor] set];
				break;
				
			case DB_POD:
				if((podFlashTimer = 1-podFlashTimer))
				   [[NSColor redColor] set];
				else
					[[NSColor blueColor] set];;
				break;
				
			case DB_SWARMER:
				[[NSColor redColor] set];
				break;
				
			case DB_HUMAN:
				[[NSColor grayColor] set];
				break;
				
			case DB_BOMB:
			case DB_BULLET:
				continue;
				break;
				
			default:
				[[NSColor purpleColor] set];
				break;
		}

		aRect.origin = anAi.worldPosition;
		aRect.origin.x -= drawPoint.x;
		if(aRect.origin.x < 0.0)
			aRect.origin.x += fieldSize.width;
		[NSBezierPath fillRect:aRect];
	}
	
	// draw the player - not in demo mode, then use fake player
	if(WCGlobals.globalsManager.renderVitals)
	{
		aRect.origin = WCGlobals.globalsManager.thePlayer.worldPosition;
		aRect.origin.x -= drawPoint.x;
		if(aRect.origin.x < 0.0)
			aRect.origin.x += fieldSize.width;
		[[NSColor whiteColor] set];
		[NSBezierPath fillRect:aRect];
	}
	else
	{
		[[NSColor whiteColor] set];
	}
	
	// Draw the screen size indicators
	[aPath setLineWidth:BG_MAP_ICON_SIZE];
	drawPoint = NSMakePoint(hfw - hvw, 40.0);
	[aPath moveToPoint:drawPoint];
	drawPoint.y = 0.0;
	[aPath lineToPoint:drawPoint];
	drawPoint.x += viewSize.width;
	[aPath lineToPoint:drawPoint];
	drawPoint.y += 40.0;
	[aPath lineToPoint:drawPoint];
	[aPath stroke];
	[aPath removeAllPoints];

	drawPoint = NSMakePoint(hfw - hvw, fieldSize.height+15.0);
	[aPath moveToPoint:drawPoint];
	drawPoint.y += 40.0;
	[aPath lineToPoint:drawPoint];
	drawPoint.x += viewSize.width;
	[aPath lineToPoint:drawPoint];
	drawPoint.y -= 40.0;
	[aPath lineToPoint:drawPoint];
	[aPath stroke];
	
	[NSGraphicsContext restoreGraphicsState];
}

/*---------------------------------------------------------------------------*/
- (void)drawStars
{
	NSRect starRect;
	NSPoint drawPoint = WCGlobals.globalsManager.drawPoint;
	CGFloat fw = WCGlobals.globalsManager.fieldSize.width;
	CGFloat endPoint = drawPoint.x + WCGlobals.globalsManager.viewSize.width;
	UInt32 i = stripIndex[(UInt32)drawPoint.x / stripWidth];

remainder:
	while(i < STARS_NUM_STARS && stars[i].frame.origin.x < endPoint)
	{
		if(!--stars[i].decay)
		{
			stars[i].visible = arc4random_uniform(2);
			stars[i].decay = STARS_MIN_HOLDTIME + (arc4random_uniform(STARS_FLICKER_WINDOW));
			stars[i].colorIndex = 1 - stars[i].colorIndex;
		}
		if(stars[i].visible)
		{
			NSColor *c = [colors objectAtIndex:stars[i].colors[stars[i].colorIndex]];
			starRect = stars[i].frame;

			[c set];
			starRect.origin.x -= drawPoint.x;
			[NSBezierPath fillRect:starRect];
		}
		++i;
	}
	
	if(endPoint > fw)
	{
		endPoint -= fw;
		drawPoint.x -= fw;
		i = 0;
		goto remainder;
	}
}

/*---------------------------------------------------------------------------*/
- (void)drawHud
{
	[self drawStars];
	[self drawGround:STARS_STRIPS_PER_SCREEN atOffset:WCGlobals.globalsManager.drawPoint];
	if(WCGlobals.globalsManager.renderVitals)
		[self showVitals];
	[self drawMinMap];
}

@end
