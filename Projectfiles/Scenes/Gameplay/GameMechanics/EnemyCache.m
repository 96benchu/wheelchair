//
//  EnemyCache.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "EnemyCache.h"
#import "BasicMonster.h"
#import "GameMechanics.h"
#import "BasicMonster.h"
#import "Knight.h"

#define ENEMY_MAX 300

@implementation EnemyCache

+(id) cache
{
	id cache = [[self alloc] init];
	return cache;
}

- (void)dealloc
{
    /* 
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id) init
{
	if ((self = [super init]))
	{
        // load all the enemies in a sprite cache, all monsters need to be part of this sprite file
        // currently the knight is used as the only monster type
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[frameCache addSpriteFramesWithFile:@"monster-animations.plist"];
        // we need to initialize the batch node with one of the frames
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster1_1.png"];
        /* A batch node allows drawing a lot of different sprites with on single draw cycle. Therefore it is necessary,
           that all sprites are added as child nodes to the batch node and that all use a texture contained in the batch node texture. */
		batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
		[self addChild:batch];
        [self scheduleUpdate];
        enemies = [[NSMutableDictionary alloc] init];
        
        /**
         A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
         Here we sign up for the 'GamePaused' and 'GameResumed' information, that is broadcasted by the GameMechanics class. Whenever the game pauses or resumes, we get informed and can react accordingly.
         **/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
	}
	
	return self;
}

- (void)gamePaused
{
    // first pause this CCNode, then pause all monsters
    
    [self pauseSchedulerAndActions];
    
    for (id key in [enemies allKeys])
    {
        NSArray *enemiesOfType = [enemies objectForKey:key];
        
        for (BasicMonster *monster in enemiesOfType)
        {
            [monster pauseSchedulerAndActions];
        }
    }
}

- (void)gameResumed
{
    // first resume this CCNode, then pause all monsters

    [self resumeSchedulerAndActions];
    
    for (id key in [enemies allKeys])
    {
        NSArray *enemiesOfType = [enemies objectForKey:key];
        
        for (BasicMonster *monster in enemiesOfType)
        {
            [monster resumeSchedulerAndActions];
        }
    }
}

-(void) spawnEnemyOfType:(Class)enemyTypeClass
{
    /* the 'enemies' dictionary stores an array of available enemies for each enemy type. 
     We use the class of the enemy as key for the dictionary, to receive an array of all existing enimies of that type.
     We use a CCArray since it has a better performance than an NSArray. */
	CCArray* enemiesOfType = [enemies objectForKey:enemyTypeClass];
    BasicMonster* enemy;
    
    /* we try to reuse existing enimies, therefore we use this flag, to keep track if we found an enemy we can
     respawn or if we need to create a new one */
    BOOL foundAvailableEnemyToSpawn = FALSE;
    
    // if the enemiesOfType array exists, iterate over all already existing enemies of the provided type and check if one of them can be respawned
    if (enemiesOfType != nil)
    {
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {
            // find the first free enemy and respawn it
            if (enemy.visible == NO)
            {
                [enemy spawn];
                // remember, that we will not need to create a new enemy
                foundAvailableEnemyToSpawn = TRUE;
                break;
            }
        }
    } else {
        // if no enemies of that type existed yet, the enemiesOfType array will be nil and we first need to create one
        enemiesOfType = [[CCArray alloc] init];
        [enemies setObject:enemiesOfType forKey:(id<NSCopying>)enemyTypeClass];
    }
    
    // if we haven't been able to find a enemy to respawn, we need to create one
    if (!foundAvailableEnemyToSpawn)
    {
        // initialize an enemy of the provided class
        BasicMonster *enemy =  [(BasicMonster *) [enemyTypeClass alloc] initWithMonsterPicture];
        [enemy spawn];
        [enemiesOfType addObject:enemy];
        [batch addChild:enemy];
    }
}

-(void) checkForCollisions
{
	BasicMonster* enemy;
    Knight *knight = [[GameMechanics sharedGameMechanics] knight];
    CGRect knightBoundingBox = [knight boundingBox];
    CGRect knightHitZone = [knight hitZone];
    
    // iterate over all enemies (all child nodes of this enemy batch)
	CCARRAY_FOREACH([batch children], enemy)
	{
        // only check for collisions if the enemy is visible
		if (enemy.visible)
		{
			CGRect bbox = [enemy boundingBox];
            /*
             1) check collision between Bounding Box of the knight and Bounding Box of the enemy.
                If a collision occurs here, only the knight can kill the enemy. The knight can not be injured by this colission. The knight can only be injured if his hit zone collides with an enemy (checked in step 2) )
             */
            // if we detect an intersection, a collision occured
            if (CGRectIntersectsRect(knightBoundingBox, bbox))
			{
                // if the knight is stabbing, or the knight is in invincible mode, the enemy will be destroyed...
                if (knight.stabbing == TRUE || knight.invincible)
                {
                    [enemy gotHit];
                    // since the enemy was hit, we can skip the second check, using 'continue'.
                    continue;
                }
			}
            /* 
             2) now we check if the knights Hit Zone collided with the enemy. If this happens, and he is not stabbing, he will be injured.
             */
            if (CGRectIntersectsRect(knightHitZone, bbox))
            {
                // if the knight is stabbing, or the knight is in invincible mode, the enemy will be destroyed...
                if (knight.stabbing == TRUE || knight.invincible)
                {
                    [enemy gotHit];
                } else
                {
                    // if the kight is not stabbing, he will be hit
                    [knight gotHit];
                }
            }
		}
	}
}


-(void) update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        updateCount++;
        
        // first we get all available monster types
        NSArray *monsterTypes = [[[GameMechanics sharedGameMechanics] spawnRatesByMonsterType] allKeys];
        
        for (Class monsterTypeClass in monsterTypes)
        {
            // we get the spawn frequency for this specific monster type
            int spawnFrequency = [[GameMechanics sharedGameMechanics] spawnRateForMonsterType:monsterTypeClass];
            
            // if the updateCount reached the spawnFrequency we spawn a new enemy
            if (updateCount % spawnFrequency == 0)
            {
                [self spawnEnemyOfType:monsterTypeClass];
            }
        }
        
        [self checkForCollisions];
    }
}

@end
