//
//  WCSoundManager.m
//  defender
//
//  Created by Stefan Wessels on 2014-11-21.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import "WCSoundManager.h"

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSoundData

@synthesize soundName;
@synthesize theSound;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@implementation WCSoundManager

@synthesize sounds;
@synthesize playing;

/*---------------------------------------------------------------------------*/
+ (id)soundManager
{
	static WCSoundManager *soundManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ soundManager = [[self alloc] init]; });
	return soundManager;
}

/*---------------------------------------------------------------------------*/
- (id)init
{
	if (self = [super init]) {
		sounds = [NSMutableArray array];
		playing = Nil;
	}
	return self;
}


/*---------------------------------------------------------------------------*/
+ (int)loadWithArray:(NSArray *)loadArray
{
	for(NSString *soundName in loadArray)
	{
		NSString *soundPathName = [[NSBundle mainBundle] pathForResource:soundName ofType:Nil];
		NSSound *aSound = [[NSSound alloc] initWithContentsOfFile:soundPathName byReference:YES];
		
		if(aSound)
		{
			WCSoundData *soundData = [WCSoundData new];
			
			soundData.soundName = [soundName stringByDeletingPathExtension];
			soundData.theSound = aSound;

			aSound.delegate = WCSoundManager.soundManager;
			
			[WCSoundManager.soundManager.sounds addObject:soundData];
		}
	}
	return 1;
}

/*---------------------------------------------------------------------------*/
+ (NSSound *)findSound:(NSString*)aSoundName;
{
	for(WCSoundData *aSound in WCSoundManager.soundManager.sounds)
	{
		if(NSOrderedSame == [aSound.soundName compare:aSoundName])
			return aSound.theSound;
	}
	return Nil;
}

/*---------------------------------------------------------------------------*/
+ (NSSound *)playSound:(NSString*)aSoundName
{
	NSSound *theSound = Nil;
	
	for(WCSoundData *aSound in WCSoundManager.soundManager.sounds)
	{
		if(NSOrderedSame == [aSound.soundName compare:aSoundName])
		{
			theSound = aSound.theSound;
			[WCSoundManager.soundManager.playing stop];
			WCSoundManager.soundManager.playing = theSound;
			[theSound play];
			break;
		}
	}
	return theSound;
}

/*---------------------------------------------------------------------------*/
+ (void)stopAllSounds
{
	[WCSoundManager.soundManager.playing stop];
	WCSoundManager.soundManager.playing = Nil;
	for(WCSoundData *aSound in WCSoundManager.soundManager.sounds)
	{
		[aSound.theSound stop];
	}
}

/*---------------------------------------------------------------------------*/
- (void)sound:(NSSound*)theSound didFinishPlaying:(BOOL)finishedPlaying
{
	WCSoundManager.soundManager.playing = Nil;
}

@end
