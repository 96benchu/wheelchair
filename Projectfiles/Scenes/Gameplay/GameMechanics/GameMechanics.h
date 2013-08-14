//
//  GameMechanics.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>
#import "Knight.h"
#import "Game.h"
#import "GameplayLayer.h"

// define the different possible GameState types, by using constants
typedef NS_ENUM(NSInteger, GameState) {
    GameStatePaused,
    GameStateMenu,
    GameStateRunning
};

/**
 This class stores several global game parameters. It stores 
 references to several entities and sets up e.g. the 'floorHeight'.
 
 This class is used by all entities in the game to access shared ressources.
**/

#define SCROLL_SPEED_DEFAULT 20.f
#define SCROLL_SPEED_SKIP_AHEAD 100.f
#define KNIGHT_HIT_POINTS 5

@interface GameMechanics : NSObject

// determines the current state the game is in. Either menu mode (scene displayed beyond main menu) or gameplay mode.
@property (nonatomic, assign) GameState gameState;

// reference to the main character
@property (nonatomic, weak) Knight *knight;

// reference to the current game object
@property (nonatomic, weak) Game *game;

@property (nonatomic, weak) Spikes *spikes;

// reference to the GamePlay-Scene
@property (nonatomic, weak) GameplayLayer *gameScene;

// sets up a gravity (used for jumping mechanism)
@property (nonatomic, assign) CGPoint worldGravity;

// sets a floor height (entities cannot move below)
@property (nonatomic, assign) float floorHeight;

// stores the scroll speed of the background (that speed influences speed of knight and enemies)
@property (nonatomic, assign) float backGroundScrollSpeedX;

// stores the individual spawn rates for all monster types
@property (nonatomic, strong, readonly) NSMutableDictionary *spawnRatesByMonsterType;



// gives access to the shared instance of this class
+ (id)sharedGameMechanics;


- (void)setSpawnRate:(int)spawnRate forMonsterType:(Class)monsterType;
- (int)spawnRateForMonsterType:(Class)monsterType;

// Resets the complete State of the sharedGameMechanics. Should be called whenever a new game is started.
- (void)resetGame;

@end
