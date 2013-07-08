//
//  GameMechanics.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "GameMechanics.h"

@implementation GameMechanics

@synthesize spawnRatesByMonsterType = _spawnRatesByMonsterType;
@synthesize gameState = _gameState;

+ (id)sharedGameMechanics
{
    static dispatch_once_t once;
    static id sharedInstance;
    /*  Uses GCD (Grand Central Dispatch) to restrict this piece of code to only be executed once
        This code doesn't need to be touched by the game developer.
     */
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    if (self)
    {
        _spawnRatesByMonsterType = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)setSpawnRate:(int)spawnRate forMonsterType:(Class)monsterType {
    NSNumber *spawnRateNumber = [NSNumber numberWithInt:spawnRate];
    [_spawnRatesByMonsterType setObject:spawnRateNumber forKey:(id<NSCopying>)monsterType];
}

- (int)spawnRateForMonsterType:(Class)monsterType {
    return [[_spawnRatesByMonsterType objectForKey:(id<NSCopying>)monsterType] intValue];
}

- (void)resetGame
{
    self.knight = nil;

    self.game = nil;
    self.gameScene = nil;
    self.worldGravity = CGPointZero;
    self.floorHeight = 0.f;
    self.gameState = GameStatePaused;
    [self.spawnRatesByMonsterType removeAllObjects];
}

- (void)setGameState:(GameState)gameState
{
    // we need to add special behaviour, when entering or leaving pause mode
    
    /**
     A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
     Here we broadcast the 'GamePausesd' and  the'GameResumed' information. All classes that listen to this notification, will be informed, that the game paused or resumed and can react accordingly.
     **/
    
    // we are leaving the paused mode and need to resume animations
    if ((_gameState == GameStatePaused) && (gameState != GameStatePaused))
    {
        // post a notification informing all screens and entities, that game is resumed        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GameResumed" object:nil];
    }
    
    // we are entering pause mode and need to pause all animations
    if ((_gameState != GameStatePaused) && (gameState == GameStatePaused))
    {
        // post a notification informing all screens and entities, that game is paused
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GamePaused" object:nil];
    }
    
    _gameState = gameState;

}
@end
