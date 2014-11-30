//
//  WCSpriteManager.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCSpriteManager.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSpriteAnim

@synthesize animName;
@synthesize numFrames;
@synthesize frameIndicies;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSpriteData

@synthesize imageName;
@synthesize image;
@synthesize numFrames;
@synthesize frameData;
@synthesize numAnims;
@synthesize animations;

/*---------------------------------------------------------------------------*/
- (WCSpriteAnim *)findAnimByName:(NSString*)aName
{
	for(WCSpriteAnim *spriteAnim in animations)
	{
		if(NSOrderedSame == [[spriteAnim animName] compare:aName])
			return spriteAnim;
	}
	return Nil;
}

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSprite

@synthesize spriteData;
@synthesize currAnim;
@synthesize position;
@synthesize srcRect;
@synthesize pivot;
@synthesize transparency;
@synthesize scale;
@synthesize rotation;

/*---------------------------------------------------------------------------*/
- (id)copyWithZone:(NSZone *)zone
{
	WCSprite *copy = [[self class] allocWithZone:zone];
	copy.spriteData = self.spriteData;
	copy.currAnim = self.currAnim;
	copy.srcRect = self.srcRect;
	copy.position = self.position;
	copy.pivot = self.pivot;
	copy.transparency = self.transparency;
	copy.scale = self.scale;
	copy.rotation = self.rotation;
	
	return copy;
}

/*---------------------------------------------------------------------------*/
- (void)setFrameInCurrAnim:(UInt32)frame
{
	srcRect = spriteData.frameData[currAnim.frameIndicies[frame]];
}

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSpriteCmd

@synthesize command;

/*---------------------------------------------------------------------------*/
- (id)copyWithZone:(NSZone *)zone
{
	WCSpriteCmd *copy = [super copyWithZone:zone];
	[super copyWithZone:zone];
	copy.command = self.command;
	
	return copy;
}

@end

/*---------------------------------------------------------------------------*
\*---------------------------------------------------------------------------*/
@implementation WCSpriteManager

@synthesize globalGFX;
@synthesize levelGFX;
@synthesize renderQueue;
@synthesize spriteQueue;

/*---------------------------------------------------------------------------*/
+ (id)spriteManager
{
	static WCSpriteManager *spriteManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ spriteManager = [[self alloc] init]; });
	return spriteManager;
}

/*---------------------------------------------------------------------------*/
- (id)init
{
	if (self = [super init]) {
		globalGFX = [NSMutableArray array];
		levelGFX = [NSMutableArray array];
		spriteQueue = [NSMutableArray array];
		renderQueue = [NSMutableArray array];
		for(int i = 0; i < RENDER_NUM_LAYERS; ++i)
		{
			[renderQueue addObject:[NSMutableArray array]];
		}
	}
	return self;
}


/*---------------------------------------------------------------------------*/
+ (int)loadWithArray:(NSArray *)loadArray inGlobal:(BOOL)global
{
	int index;
	NSMutableArray *dataArray = global ? WCSpriteManager.spriteManager.globalGFX : WCSpriteManager.spriteManager.levelGFX;

	for(NSDictionary *imageDict in loadArray)
	{
		NSString *imageName = [imageDict objectForKey:@"bitmap"];
		NSString *imagePathName = [[NSBundle mainBundle] pathForResource:imageName ofType:Nil];
		NSImage *anImage = [[NSImage alloc] initWithContentsOfFile:imagePathName];

		if(anImage)
		{
			WCSpriteData *spriteData = [WCSpriteData new];
			NSArray *frames = [imageDict objectForKey:@"frames"];
			
			spriteData.imageName = imageName;
			spriteData.image = anImage;
			spriteData.numFrames = (UInt32)[frames count];

			if(spriteData.numFrames)
			{
				index = 0;
				spriteData.frameData = (NSRect*)malloc(sizeof(NSRect) * spriteData.numFrames);
				for(NSString *rectString in frames)
				{
					NSRect aRect = NSRectFromString(rectString);
					spriteData.frameData[index++] = aRect;
				}
			}

			NSArray *anims = [imageDict objectForKey:@"anims"];
			spriteData.numAnims = (UInt32)[anims count];
			
			if(spriteData.numAnims)
			{
				NSMutableArray *tempAnimArray = [[NSMutableArray alloc] initWithCapacity:spriteData.numAnims];
				for(NSDictionary *animDict in anims)
				{
					WCSpriteAnim *spriteAnim = [WCSpriteAnim new];

					spriteAnim.animName = [animDict objectForKey:@"animName"];
					NSArray *animFrames = [animDict objectForKey:@"frameIndex"];
					spriteAnim.numFrames = (UInt32)[animFrames count];
					if(spriteAnim.numFrames)
					{
						spriteAnim.frameIndicies = (UInt32*)malloc(sizeof(UInt32)*spriteAnim.numFrames);
						for(index=0; index < spriteAnim.numFrames; ++index)
						{
							spriteAnim.frameIndicies[index] = (UInt32)[[animFrames objectAtIndex:index] integerValue];
						}
					}
					
					[tempAnimArray addObject:spriteAnim];
				}
				spriteData.animations = [NSArray arrayWithArray:tempAnimArray];
			}
			
			[dataArray addObject:spriteData];
		}
	}
	return 1;
}

/*---------------------------------------------------------------------------*/
+(void) renderSprite:(WCSprite *)aSprite onLayer:(UInt32)aLayer withCopy:(BOOL)copy
{
	WCSprite *renderSprite;
	
	if(copy)
		renderSprite = [aSprite copy];
	else
		renderSprite = aSprite;
	
	[[WCSpriteManager.spriteManager.renderQueue objectAtIndex:aLayer] addObject:renderSprite];
}

/*---------------------------------------------------------------------------*/
+ (id) makeSpriteClass:(Class)aClass fromImage:(NSString *)imageName forAnim:(NSString *)animName
{
	WCSpriteData *spriteData = [WCSpriteManager findImageByNameInAll:imageName];
	if(spriteData)
	{
		WCSpriteAnim *spriteAnim = [spriteData findAnimByName:animName];
		
		WCSprite *aSprite = [aClass new];
		aSprite.spriteData = spriteData;
		aSprite.currAnim = spriteAnim;
		aSprite.srcRect = spriteData.frameData[spriteAnim ? spriteAnim.frameIndicies[0] : 0];
		aSprite.position = NSMakePoint(0.0, 0.0);
		aSprite.pivot = NSMakePoint(aSprite.srcRect.size.width/2.0, aSprite.srcRect.size.height/2.0);
		aSprite.scale = NSMakePoint(1.0, 1.0);
		aSprite.transparency = 1.0;
		
		return aSprite;
	}
	return Nil;
}

/*---------------------------------------------------------------------------*/
+ (WCSprite *) makeSpriteFromImage:(NSString *)imageName forAnim:(NSString *)animName
{
	return [self makeSpriteClass:[WCSprite class] fromImage:imageName forAnim:animName];
}

/*---------------------------------------------------------------------------*/
+ (WCSpriteData *) findImageByName:(NSString *)aName inGlobal:(BOOL)global
{
	NSMutableArray *dataArray = global ? WCSpriteManager.spriteManager.globalGFX : WCSpriteManager.spriteManager.levelGFX;

	for(WCSpriteData *spriteData in dataArray)
	{
		if(NSOrderedSame == [aName compare:spriteData.imageName])
			return spriteData;
	}
	return Nil;
}

/*---------------------------------------------------------------------------*/
+ (WCSpriteData *) findImageByNameInAll:(NSString *)aName
{
	WCSpriteData *spriteData = [self findImageByName:aName inGlobal:YES];
	if(!spriteData)
		spriteData = [self findImageByName:aName inGlobal:NO];
	
	return spriteData;
}

@end
