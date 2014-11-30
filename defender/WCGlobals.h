//
//  WCGlobals.h
//  defender
//
//  Created by Stefan Wessels on 2014-11-02.
//  Copyright (c) 2014 Wessels Consulting Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*---------------------------------------------------------------------------*/
/* The order in this enum matters as it's an index into ex. _tagImpTemplate
 * as well as into DB_STRINGS
 */
enum
{
	DB_LOGO_PNG,
	DB_PLAYER,
	DB_LANDER,
	DB_MUTANT,
	DB_BAITER,
	DB_BOMBER,
	DB_POD,
	DB_SWARMER,
	DB_HUMAN,
	DB_BOMB,
	DB_BULLET,
	DB_THRUST,
	DB_IDLE,
	DB_LASERS,
	DB_COLORS,
	DB_SMARTBOMB,
	DB_SPRITES_PNG,
	DB_FONT_PNG,
	DB_WESSELS_PNG,
	DB_WESSELS,
	DB_START,
	DB_INBOUND,
	DB_LASER,
	DB_LANDERDIE,
	DB_BOMBERDIE,
	DB_PLAYERDIE,
	DB_HUMANFALL,
	DB_HUMANCATCH,
	DB_HUMANPICKUP,
	DB_LANDERSHOOT,
	DB_MUTANTSHOOT,
	DB_SWARMERSHOOT,
	DB_WORLDEXPLODE,
	DB_SCORETABLE,
	DB_CONFIG,
	DB_NUM_STRINGS
};
extern NSString *DB_STRINGS[DB_NUM_STRINGS];
extern const UInt32 DB_SCORES[DB_NUM_STRINGS];

#define SPRITE_SCALE				3.0

#define	GAME_FPS					30
#define GAME_SECONDS(x)				(GAME_FPS * x)

#define RADS(x)						((CGFloat)(x)*(M_PI/180.0))

#define GAME_SCORE_SAVE_HUMAN		500
#define	GAME_SCORE_HUMAN_FALL_SAFE	250
#define GAME_SCORE_HUMAN_SURVIVED	100
#define GAME_SCORE_BONUS_SCORE		10000
#define WESSELS_SIZE				1.67
#define LOGO_SIZE					2.0

#define SWARMER_SEEK_TIME			GAME_SECONDS(0.75)
#define LANDER_SHOOT_WINDOW			(arc4random_uniform(GAME_SECONDS(4)) + GAME_SECONDS(0.25))
#define MUTANT_SHOOT_WINDOW			(arc4random_uniform(GAME_SECONDS(1.5)))
#define SWARMER_SHOOT_WINDOW		(arc4random_uniform(GAME_SECONDS(4)) + SWARMER_SEEK_TIME)

enum
{
	WCCOLOR_RED,
	WCCOLOR_YELLOW,
	WCCOLOR_GREEN,
	WCCOLOR_CYAN,
	WCCOLOR_BLUE,
	WCCOLOR_PURPLE,
	WCCOLOR_WHITE,
};

#define WCCOLOR_0				WCCOLOR_RED
#define WCCOLOR_NUM_COLORS		(WCCOLOR_WHITE+1)
#define WCCOLOR_BROWN			WCCOLOR_NUM_COLORS	// Brown is a special color, not in fonts
#define MAX_NUM_PLAYERS			2
#define NUM_HIGH_SCORES			8

@class WCSprite;
@class WCAIs;
@class WCBackground;
@class WCEffects;
@class WCPlayer;

typedef struct _tagWCHighScore
{
	UInt32	score;
	char	initials[4];
} WCHighScore;

/*---------------------------------------------------------------------------*\
\*---------------------------------------------------------------------------*/
@interface WCGlobals : NSObject
{
								UInt32			score[MAX_NUM_PLAYERS];
								UInt32			lives[MAX_NUM_PLAYERS];
								UInt32			smartBombs[MAX_NUM_PLAYERS];
								UInt32			numHumans[MAX_NUM_PLAYERS];
								UInt32			numLanders[MAX_NUM_PLAYERS];
								UInt32			numMutants[MAX_NUM_PLAYERS];
								UInt32			numBombers[MAX_NUM_PLAYERS];
								UInt32			numPods[MAX_NUM_PLAYERS];
								UInt32			numSwarmers[MAX_NUM_PLAYERS];
								UInt32			totalEnemiesTiKill[MAX_NUM_PLAYERS];
								UInt32			aiLevel[MAX_NUM_PLAYERS];
								BOOL			groundOkay[MAX_NUM_PLAYERS];
								UInt32			prefItem[2];
};

@property (nonatomic, retain)	WCBackground	*theBackground;
@property (nonatomic, retain)	WCAIs			*theAIs;
@property (nonatomic, retain)	WCPlayer		*thePlayer;
@property (nonatomic, retain)	WCEffects		*theEffects;
@property						NSSize			fieldSize;
@property						CGFloat			velocity;
@property						UInt32			renderHUD;
@property						UInt32			renderVitals;
@property						UInt32			numActivePlayers;
@property						UInt32			activePlayer;
@property						BOOL			hasScored;
@property						WCHighScore		*todaysHighScores;
@property						WCHighScore		*allTimeHighScores;
@property						NSRect			viewRect;
@property						BOOL			prefsActive;
@property						BOOL			joystickScreen;



+ (WCGlobals*)globalsManager;
- (id)init;
- (void)makeObjects;
- (NSPoint)drawPoint;
- (void)setDrawPoint:(NSPoint)aPoint;
- (NSSize)viewSize;
- (void)setViewSize:(NSSize)aSize;

+ (BOOL)WCPointInView:(NSPoint)aPoint;
+ (void)evalCubicCurrPos:(CGFloat*)y0 currSpeed:(CGFloat*)m0 destPos:(CGFloat)y1 timeStep:(CGFloat)t;

- (UInt32)nextActivePlayer;

- (UInt32)score;
- (void)setScore:(UInt32)aScore;
- (void)addToScore:(UInt32)aScore;
- (UInt32)theScore:(UInt32)aPlayer;

- (UInt32)lives;
- (void)setLives:(UInt32)aLives;
- (void)addToLives:(UInt32)aLives;
- (UInt32)theLives:(UInt32)aPlayer;

- (UInt32)smartBombs;
- (void)setSmartBombs:(UInt32)aSmartBombs;
- (void)addToSmartBombs:(UInt32)aSmartBombs;
- (UInt32)theSmartBombs:(UInt32)aPlayer;

- (UInt32)numHumans;
- (void)setNumHumans:(UInt32)aNumHumans;

- (UInt32)numLanders;
- (void)setNumLanders:(UInt32)aNumLanders;

- (UInt32)numMutants;
- (void)setNumMutants:(UInt32)aNumMutants;

- (UInt32)numBombers;
- (void)setNumBombers:(UInt32)aNumBombers;

- (UInt32)numPods;
- (void)setNumPods:(UInt32)aNumPods;

- (UInt32)numSwarmers;
- (void)setNumSwarmers:(UInt32)aNumSwarmers;

- (UInt32)totalEnemiesTiKill;
- (void)setTotalEnemiesTiKill:(UInt32)aNumTotalEnemiesTiKill;

- (UInt32)aiLevel;
- (void)setAiLevel:(UInt32)aLevel;

- (BOOL)groundOkay;
- (void)setGroundOkay:(BOOL)aOkay;

- (UInt32)prefItem:(UInt32)aScreen;
- (void)setPrefItem:(UInt32)anItem forScreen:(UInt32)aScreen;

@end
