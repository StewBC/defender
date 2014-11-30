//
//  WCSpriteManager.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*/
enum
{
	RENDER_LAYER_AI,
	RENDER_LAYER_PLAYER,
	RENDER_LAYER_TEXT,
	RENDER_NUM_LAYERS
};

enum
{
	RENDER_COMMAND_POP				= 0,
	RENDER_COMMAND_TRANSLATE		= 1,
	RENDER_COMMAND_SCALE			= 2,
	RENDER_COMMAND_ROTATE			= 4
};

/*---------------------------------------------------------------------------*\
  These objects live in the animation array in WCSpriteData
\*---------------------------------------------------------------------------*/
@interface WCSpriteAnim : NSObject

@property (nonatomic, copy)		NSString			*animName;
@property						UInt32				numFrames;
@property						UInt32				*frameIndicies;	// malloc array

@end

/*---------------------------------------------------------------------------*\
  These objects live in WCSpriteManager *GFX arrays
\*---------------------------------------------------------------------------*/
@interface WCSpriteData : NSObject

@property (nonatomic, copy)		NSString			*imageName;
@property (nonatomic, retain)	NSImage				*image;
@property						UInt32				numFrames;
@property						NSRect				*frameData;		// malloc array
@property						UInt32				numAnims;
@property (nonatomic, copy)		NSArray				*animations;

- (WCSpriteAnim *)findAnimByName:(const NSString*)aName;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCSprite : NSObject
{
	NSRect srcRect;
}
@property (nonatomic, retain)	WCSpriteData		*spriteData;
@property (nonatomic, weak)		WCSpriteAnim		*currAnim;
@property						NSPoint				position;
@property						NSRect				srcRect;
@property						NSPoint				pivot;
@property						CGFloat				transparency;
@property						NSPoint				scale;
@property						CGFloat				rotation;

- (id)copyWithZone:(NSZone *)zone;
- (void)setFrameInCurrAnim:(const UInt32)frame;
@end


/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCSpriteCmd : WCSprite

- (id)copyWithZone:(NSZone *)zone;

@property						UInt32				command;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCSpriteManager : NSObject

@property (nonatomic, copy) NSMutableArray		*globalGFX;
@property (nonatomic, copy) NSMutableArray		*levelGFX;
@property (nonatomic, copy) NSMutableArray		*renderQueue;
@property (nonatomic, copy) NSMutableArray		*spriteQueue;

+(WCSpriteManager *) spriteManager;
+ (int)loadWithArray:(const NSArray *)loadArray inGlobal:(const BOOL)global;
+ (void)renderSprite:(WCSprite *)aSprite onLayer:(const UInt32)aLayer withCopy:(const BOOL)copy;
+ (id)makeSpriteClass:(Class)aClass fromImage:(const NSString *)imageName forAnim:(const NSString *)animName;
+ (WCSprite *)makeSpriteFromImage:(const NSString *)imageName forAnim:(const NSString *)animName;

+ (WCSpriteData *)findImageByName:(const NSString *)aName inGlobal:(const BOOL)global;
+ (WCSpriteData *)findImageByNameInAll:(const NSString *)aName;
@end
