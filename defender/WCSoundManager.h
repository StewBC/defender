//
//  WCSoundManager.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-21.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCSoundData : NSObject

@property (nonatomic, copy)		NSString			*soundName;
@property (nonatomic, retain)	NSSound				*theSound;

@end

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCSoundManager : NSObject<NSSoundDelegate>

@property (nonatomic, copy)		NSMutableArray		*sounds;
@property (nonatomic, retain)	NSSound				*playing;

+ (WCSoundManager *) soundManager;
+ (int)loadWithArray:(const NSArray *)loadArray;
+ (NSSound *)findSound:(NSString*)aSoundName;
+ (NSSound *)playSound:(NSString*)aSoundName;
+ (void)stopAllSounds;
- (void)sound:(NSSound*)aSound didFinishPlaying:(BOOL)finishedPlaying;

@end
