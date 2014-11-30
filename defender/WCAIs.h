//
//  WCAIs.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WCAISprite;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCAIs : NSObject

@property (nonatomic, copy)	NSMutableArray	*aiList;
@property (nonatomic, copy)	NSMutableArray	*humansList;
@property (nonatomic, copy)	NSMutableArray	*fixupList;
@property					UInt32			aiState;
@property					UInt32			nextWaveTime;
@property					BOOL			madeMutants;
@property					UInt32			numLandersToSpawn;
@property					UInt32			numLandersSpawned;
@property					UInt32			lastKillTimer;

- (id)init;
- (void)setupEnemyNumbers;
- (void)resetAi;
- (void)resetKillTimer;
- (void)createHumans:(UInt32)number;
- (BOOL)create:(UInt32)number ofClass:(Class)aClass forAnimIdx:(UInt32)animIdx;
- (void)create:(UInt32)number bombersForAnimIdx:(UInt32)animIdx;
- (void)landersToMutants;
- (void)processFixupList;
- (void)explodeAi:(WCAISprite*)anAi;
- (void)run:(UInt32)frameCounter;

@end
