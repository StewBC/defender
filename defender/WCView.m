//
//  WCView.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCView.h"
#import "WCGlobals.h"
#import "WCInputManager.h"
#import "WCSoundManager.h"
#import "WCTextout.h"
#import "WCPrefs.h"
#import "WCBackground.h"
#import "WCMainLoop.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCView

@synthesize theMainLoop;
@synthesize sceneRect;
@synthesize spriteCmdStack;

/*---------------------------------------------------------------------------*/
- (void)awakeFromNib
{
	NSString *pSpriteListPathName = [[NSBundle mainBundle] pathForResource:@"sprites" ofType:@"plist"];
	NSString *pSoundListPathName = [[NSBundle mainBundle] pathForResource:@"sounds" ofType:@"plist"];
	NSArray *pSpriteList = [[NSArray alloc] initWithContentsOfFile:pSpriteListPathName];
	NSArray *pSoundList = [[NSArray alloc] initWithContentsOfFile:pSoundListPathName];
	
	[self.window setBackgroundColor:[NSColor blackColor]];

	if(pSpriteList && pSoundList && [WCSpriteManager loadWithArray:pSpriteList inGlobal:YES] && [WCSoundManager loadWithArray:pSoundList])
	{
		sceneRect = [self bounds];

		// This creates the globals instance
		WCGlobals.globalsManager.viewSize = sceneRect.size;

		[WCInputManager inputManager];
		// This work can't be in WCGlobal's init as some objects
		// refer to elements in WCGlobals in their init
		[WCGlobals.globalsManager makeObjects];
		theMainLoop = [[WCMainLoop alloc] init:self];

		spriteCmdStack = [NSMutableArray array];
		
		// Read the all-time best high-scores
		[self loadScores];
		[self loadInputConf];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];

		[NSTimer scheduledTimerWithTimeInterval:1.0/GAME_FPS target:theMainLoop selector:@selector(mainLoop:) userInfo:Nil repeats:YES];
	}
}

/*---------------------------------------------------------------------------*/
- (IBAction)showPrefs:(id)sender
{
	WCGlobals.globalsManager.prefsActive = 1;
}

/*---------------------------------------------------------------------------*/
- (NSURL*)appSupportURL
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSURL *supportUrl = nil;
	
	NSArray *urls = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
	NSString *bundleURL = [[NSBundle mainBundle] bundleIdentifier];
	
	for(NSURL *aSupportURL in urls)
	{
		NSArray *supportDirURLs = [[NSFileManager defaultManager]
								   contentsOfDirectoryAtURL:aSupportURL
								   includingPropertiesForKeys:nil
								   options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants |
								   NSDirectoryEnumerationSkipsPackageDescendants |
								   NSDirectoryEnumerationSkipsHiddenFiles)
								   error:&error];
		
		for(NSURL *aURL in supportDirURLs)
		{
			if(NSOrderedSame == [[[aURL path] lastPathComponent] compare:bundleURL options:NSLiteralSearch])
			{
				supportUrl = aURL;
				break;
			}
		}
		if(supportUrl)
			break;
	}
	
	if(!supportUrl)
	{
		for(NSURL *aSupportURL in urls)
		{
			supportUrl = [NSURL URLWithString:bundleURL relativeToURL:aSupportURL];
			if([fileManager createDirectoryAtPath:[supportUrl path] withIntermediateDirectories:NO attributes:NULL error:&error])
				break;
			else
				supportUrl = Nil;
		}
	}
	
	return supportUrl ;
}

/*---------------------------------------------------------------------------*/
- (void)loadScores
{
	NSURL *supportURL = [self appSupportURL];
	NSURL *scoresURL = [NSURL URLWithString:DB_STRINGS[DB_SCORETABLE] relativeToURL:supportURL];
	scoresURL = [scoresURL URLByAppendingPathExtension:@"plist"];

	NSDictionary *scoresDict = [NSDictionary dictionaryWithContentsOfURL:scoresURL];
	if(scoresDict)
	{
		WCHighScore *ahs = WCGlobals.globalsManager.allTimeHighScores;
		
		for(UInt32 i = 0; i < NUM_HIGH_SCORES; ++i)
		{
			NSString *aName = [scoresDict objectForKey:[NSString stringWithFormat:@"Name%d",i]];
			NSString *aScore = [scoresDict objectForKey:[NSString stringWithFormat:@"Score%d",i]];
			[aName getCString:ahs[i].initials maxLength:4 encoding:NSASCIIStringEncoding];
			ahs[i].score = [aScore intValue];
		}
	}
}

/*---------------------------------------------------------------------------*/
- (void)saveScores
{
	NSURL *supportURL = [self appSupportURL];
	if(supportURL)
	{
		NSURL *scoresURL = [NSURL URLWithString:DB_STRINGS[DB_SCORETABLE] relativeToURL:supportURL];
		scoresURL = [scoresURL URLByAppendingPathExtension:@"plist"];
		
		WCHighScore *ahs = WCGlobals.globalsManager.allTimeHighScores;
		NSMutableDictionary *scoresDict = [NSMutableDictionary new];
		for(UInt32 i = 0; i < NUM_HIGH_SCORES; ++i)
		{
			[scoresDict setObject:[NSString stringWithFormat:@"%.3s",ahs[i].initials] forKey:[NSString stringWithFormat:@"Name%d",i]];
			[scoresDict setObject:[NSString stringWithFormat:@"%d",ahs[i].score] forKey:[NSString stringWithFormat:@"Score%d",i]];
		}
		[scoresDict writeToURL:scoresURL atomically:NO];
	}
}

/*---------------------------------------------------------------------------*/
- (void)loadInputConf
{
	NSURL *supportURL = [self appSupportURL];
	NSURL *inputURL = [NSURL URLWithString:DB_STRINGS[DB_CONFIG] relativeToURL:supportURL];
	inputURL = [inputURL URLByAppendingPathExtension:@"plist"];
	
	NSDictionary *inputDict = [NSDictionary dictionaryWithContentsOfURL:inputURL];
	if(inputDict)
	{
		UInt32 *kmp = g_keyMap;
		WCJoyMap *jmp = g_joyMap;

		for(UInt32 i = 0; i < g_numKeys; ++i)
		{
			NSString *aName = [inputDict objectForKey:[NSString stringWithFormat:@"key%d",i]];
			kmp[i] = [aName intValue];
		}

		for(UInt32 i = 0; i < g_numJoyCntrls; ++i)
		{
			NSString *aCode = [inputDict objectForKey:[NSString stringWithFormat:@"joyC%d",i]];
			NSString *aPage = [inputDict objectForKey:[NSString stringWithFormat:@"joyP%d",i]];
			NSString *aValue = [inputDict objectForKey:[NSString stringWithFormat:@"joyV%d",i]];
			jmp[i].code = [aCode intValue];
			jmp[i].page = [aPage intValue];
			jmp[i].value = [aValue intValue];
		}
	}
}

/*---------------------------------------------------------------------------*/
- (void)saveInputConf
{
	NSURL *supportURL = [self appSupportURL];
	if(supportURL)
	{
		NSURL *inputURL = [NSURL URLWithString:DB_STRINGS[DB_CONFIG] relativeToURL:supportURL];
		inputURL = [inputURL URLByAppendingPathExtension:@"plist"];
		
		UInt32 *kmp = g_keyMap;
		WCJoyMap *jmp = g_joyMap;
		
		NSMutableDictionary *inputDict = [NSMutableDictionary new];

		for(UInt32 i = 0; i < g_numKeys; ++i)
		{
			[inputDict setObject:[NSString stringWithFormat:@"%d",kmp[i]] forKey:[NSString stringWithFormat:@"key%d",i]];
		}

		for(UInt32 i = 0; i < g_numJoyCntrls; ++i)
		{
			[inputDict setObject:[NSString stringWithFormat:@"%d",jmp[i].code] forKey:[NSString stringWithFormat:@"joyC%d",i]];
			[inputDict setObject:[NSString stringWithFormat:@"%d",jmp[i].page] forKey:[NSString stringWithFormat:@"joyP%d",i]];
			[inputDict setObject:[NSString stringWithFormat:@"%ld",jmp[i].value] forKey:[NSString stringWithFormat:@"joyV%d",i]];
		}
		[inputDict writeToURL:inputURL atomically:NO];
	}
}

/*---------------------------------------------------------------------------*/
- (void)windowWillClose:(NSNotification *)notification
{
	[self saveScores];
	[self saveInputConf];
	[NSApp terminate:self];
}

/*---------------------------------------------------------------------------*/
// make sure keys come here
- (BOOL)acceptsFirstResponder
{
	return YES;
}

/*---------------------------------------------------------------------------*/
// Do nothing but this silences the unhandled key beeps
- (void)keyDown:(NSEvent *)theEvent
{
//	NSLog(@"Key %@",[theEvent description]);
}

/*---------------------------------------------------------------------------*/
- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	NSAffineTransform *xform;
	BOOL spriteScaled = NO;
	NSPoint scale = NSMakePoint(1.0, 1.0);
	NSPoint identPoint = NSMakePoint(1.0, 1.0);

// Uncomment to see the frame rate
//	static CFTimeInterval startTime;
//	CFTimeInterval endTime = CACurrentMediaTime();
//	CFTimeInterval elapsed = endTime - startTime;
//	startTime = endTime;
//	[WCTextout printAtX:8 atY:WCGlobals.globalsManager.viewSize.height-8.0 theString:[NSString stringWithFormat:@"FPS: %2.f",1.0/elapsed] atScale:2.0 inFont:WCCOLOR_CYAN orAttribs:Nil];

	// Scale for full-screen
	NSSize viewScale;
	viewScale.width = dirtyRect.size.width / sceneRect.size.width;
	viewScale.height = dirtyRect.size.height / sceneRect.size.height;
	if(viewScale.width != 1.0 || viewScale.height != 1.0)
	{
		xform = [NSAffineTransform transform];
		[xform scaleXBy:viewScale.width yBy:viewScale.height];
		[xform concat];
		xform = Nil;
	}

	if(WCGlobals.globalsManager.renderHUD)
		[WCGlobals.globalsManager.theBackground drawHud];

	if(WCGlobals.globalsManager.prefsActive)
		[theMainLoop.thePrefs draw];
	
	for(NSMutableArray *layer in WCSpriteManager.spriteManager.renderQueue)
	{
		if([layer count])
		{
			for(WCSprite *aSprite in layer)
			{
				if([aSprite isKindOfClass:[WCSpriteCmd class]])
				{
					BOOL popAction = NO;
					WCSpriteCmd *spriteCmd = (WCSpriteCmd*)aSprite;
					UInt32 command = spriteCmd.command;
					xform = [NSAffineTransform transform];
					
					if(RENDER_COMMAND_POP == command)
					{
						popAction = YES;
						spriteCmd = [spriteCmdStack lastObject];
						command = spriteCmd.command;
					}

					if(RENDER_COMMAND_ROTATE & command)
					{
						[xform translateXBy:aSprite.pivot.x yBy:aSprite.pivot.y];
						[xform rotateByDegrees:aSprite.rotation];
						[xform translateXBy:-aSprite.pivot.x yBy:-aSprite.pivot.y];
					}
					
					if(RENDER_COMMAND_TRANSLATE & command)
						[xform translateXBy:spriteCmd.position.x yBy:spriteCmd.position.y];
					
					if(RENDER_COMMAND_SCALE & command)
					{
						if(popAction)
						{
							scale.x /= spriteCmd.scale.x;
							scale.y /= spriteCmd.scale.y;
						}
						else
						{
							scale.x *= spriteCmd.scale.x;
							scale.y *= spriteCmd.scale.y;
						}
						[xform scaleXBy:spriteCmd.scale.x yBy:spriteCmd.scale.y];
					}
					if(popAction)
					{
						[spriteCmdStack removeLastObject];
						[xform invert];
					}
					else
						[spriteCmdStack addObject:spriteCmd];
					
					[xform concat];
					continue;
				}

				xform = Nil;
				
				if(aSprite.rotation)
				{
					xform = [NSAffineTransform transform];
					[xform translateXBy:aSprite.position.x yBy:aSprite.position.y];
					[xform rotateByDegrees:aSprite.rotation];
					[xform translateXBy:-aSprite.position.x yBy:-aSprite.position.y];
				}

				if(!NSEqualPoints(aSprite.scale, identPoint))
				{
					if(!xform)
						xform = [NSAffineTransform transform];
					scale.x *= aSprite.scale.x;
					scale.y *= aSprite.scale.y;
					spriteScaled = YES;
					[xform scaleXBy:aSprite.scale.x yBy:aSprite.scale.y];
				}
				
				if(xform)
					[xform concat];
				
				NSPoint drawPos = aSprite.position;
				drawPos.x /= scale.x;
				drawPos.y /= scale.y;
				drawPos.x -= aSprite.pivot.x;
				drawPos.y -= aSprite.pivot.y;

				[aSprite.spriteData.image drawAtPoint:drawPos fromRect:aSprite.srcRect operation:NSCompositingOperationSourceOver fraction:aSprite.transparency];
				
				if(xform)
				{
					if(spriteScaled)
					{
						scale.x /= aSprite.scale.x;
						scale.y /= aSprite.scale.y;
						spriteScaled = NO;
					}
					[xform invert];
					[xform concat];
				}
			}
			[layer removeAllObjects];
//			[spriteCmdStack removeAllObjects];
		}
	}
//	NSAssert(0 == [spriteCmdStack count], @"spriteCmdStack not empty");
}

@end
