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
#import "Truth.h"
#import "Coins.h"


#define ENEMY_MAX 100

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
        foundEnemy1 = false;
        foundEnemy2 = false;
        foundEnemy3 = false;
        foundEnemy4 = false;
        foundEnemy5 = false;
        // load all the enemies in a sprite cache, all monsters need to be part of this sprite file
        // currently the knight is used as the only monster type
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *rampFrame = [[CCSprite spriteWithFile:@"ramp.png"] displayFrame];
        CCSpriteFrameCache* frameCache2 = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *boxFrame = [[CCSprite spriteWithFile:@"basicbarrell.png"] displayFrame];
        CCSpriteFrameCache* frameCache3 = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *coinFrame = [[CCSprite spriteWithFile:@"coin1.png"] displayFrame];
        CCSpriteFrameCache* frameCache4 = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *box2Frame = [[CCSprite spriteWithFile:@"basicbarrell.png"] displayFrame];
        CCSpriteFrameCache* frameCache5 = [CCSpriteFrameCache sharedSpriteFrameCache];
        CCSpriteFrame *box3Frame = [[CCSprite spriteWithFile:@"basicbarrell.png"] displayFrame];

		[frameCache addSpriteFrame:rampFrame name:@"ramp.png"];
        [frameCache2 addSpriteFrame:boxFrame name:@"basicbarrell.png"];
        [frameCache3 addSpriteFrame:coinFrame name:@"coin1.png"];
        [frameCache4 addSpriteFrame:box2Frame name:@"basicbarrell.png"];
        [frameCache5 addSpriteFrame:box3Frame name:@"basicbarrell.png"];
        // we need to initialize the batch node with one of the frames
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"ramp.png"];
        CCSpriteFrame* frame2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"basicbarrell.png"];
        CCSpriteFrame* frame3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"coin1.png"];
        CCSpriteFrame* frame4 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"basicbarrell.png"];
        CCSpriteFrame* frame5 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"basicbarrell.png"];

        /* A batch node allows drawing a lot of different sprites with on single draw cycle. Therefore it is necessary,
           that all sprites are added as child nodes to the batch node and that all use a texture contained in the batch node texture. */
		batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
        batch2 = [CCSpriteBatchNode batchNodeWithTexture:frame2.texture];
        batch3 = [CCSpriteBatchNode batchNodeWithTexture:frame3.texture];
        batch4 = [CCSpriteBatchNode batchNodeWithTexture:frame4.texture];
        batch5 = [CCSpriteBatchNode batchNodeWithTexture:frame5.texture];
		[self addChild:batch];
        [self addChild:batch2];
        [self addChild:batch3];
        [self addChild:batch4];
        [self addChild:batch5];
        [self scheduleUpdate];
        enemies = [[NSMutableDictionary alloc] init];
        enemies2= [[NSMutableDictionary alloc] init];
        enemies3 = [[NSMutableDictionary alloc] init];
        enemies4 = [[NSMutableDictionary alloc] init];
        enemies5 = [[NSMutableDictionary alloc] init];
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
/*
-(void) spawnEnemyOfType5
{
    CCArray* enemiesOfType = [enemies4 objectForKey:[Box3 class]];
    Box3* enemy;
    Truth* data = [Truth sharedData];
    BOOL foundAvailableEnemyToSpawn = FALSE;
    
    // if the enemiesOfType array exists, iterate over all already existing enemies of the provided type and check if one of them can be respawned
    if (enemiesOfType != nil)
    {
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {
            if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
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
        }
    } else {
        if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
        {
            
            //NSLog(@"YEAP2");
            // if no enemies of that type existed yet, the enemiesOfType array will be nil and we first need to create one
            enemiesOfType = [[CCArray alloc] init];
            [enemies5 setObject:enemiesOfType forKey:(id<NSCopying>)[Box3 class]];
        }
        
    }
    
    // if we haven't been able to find a enemy to respawn, we need to create one
    if (!foundEnemy5)
    {
        
        if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
        {
            //NSLog(@"Spawn2");
            // initialize an enemy of the provided class
            Box3 *enemy =  [(Box3 *) [[Box3 class] alloc] initWithBoxImage];
            [enemy spawn];
            [enemiesOfType addObject:enemy];
            
            [batch5 addChild:enemy];
            foundEnemy2 = true;
        }
    }
    
}

-(void) spawnEnemyOfType4
{
    CCArray* enemiesOfType = [enemies4 objectForKey:[Box2 class]];
    Box2* enemy;
    Truth* data = [Truth sharedData];
    BOOL foundAvailableEnemyToSpawn = FALSE;
    
    // if the enemiesOfType array exists, iterate over all already existing enemies of the provided type and check if one of them can be respawned
    if (enemiesOfType != nil)
    {
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {
            if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
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
        }
    } else {
        if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
        {
            
            //NSLog(@"YEAP2");
            // if no enemies of that type existed yet, the enemiesOfType array will be nil and we first need to create one
            enemiesOfType = [[CCArray alloc] init];
            [enemies4 setObject:enemiesOfType forKey:(id<NSCopying>)[Box2 class]];
        }
        
    }
    
    // if we haven't been able to find a enemy to respawn, we need to create one
    if (!foundEnemy4)
    {
        
        if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
        {
            //NSLog(@"Spawn2");
            // initialize an enemy of the provided class
            Box2 *enemy =  [(Box2 *) [[Box2 class] alloc] initWithBoxImage];
            [enemy spawn];
            [enemiesOfType addObject:enemy];
            
            [batch4 addChild:enemy];
            foundEnemy2 = true;
        }
    }
    
}*/

-(void) spawnEnemyOfType2
{
    CCArray* enemiesOfType = [enemies2 objectForKey:[Box1 class]];
    Box1* enemy;
    Truth* data = [Truth sharedData];
    BOOL foundAvailableEnemyToSpawn = FALSE;
    
    // if the enemiesOfType array exists, iterate over all already existing enemies of the provided type and check if one of them can be respawned
    if (enemiesOfType != nil)
    {
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {
            if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
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
        }
    } else {
        if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
        {
            
            //NSLog(@"YEAP2");
            // if no enemies of that type existed yet, the enemiesOfType array will be nil and we first need to create one
            enemiesOfType = [[CCArray alloc] init];
            [enemies2 setObject:enemiesOfType forKey:(id<NSCopying>)[Box1 class]];
        }
        
    }
    
    // if we haven't been able to find a enemy to respawn, we need to create one
    if (!foundEnemy2)
    {
        
        if((data.onRamp == false) && (-1*data.scrollSpeed > 150))
        {
            
            //NSLog(@"Spawn2");
            // initialize an enemy of the provided class
            Box1 *enemy =  [(Box1 *) [[Box1 class] alloc] initWithBoxImage];
            [enemy spawn];
            [enemiesOfType addObject:enemy];
            
            [batch2 addChild:enemy];
            foundEnemy2 = true;
        }
    }
    
}
-(void) spawnEnemyOfType3
{
    CCArray* enemiesOfType = [enemies3 objectForKey:[Coins class]];
      Coins* enemy;
    Truth* data = [Truth sharedData];
    BOOL foundAvailableEnemyToSpawn = FALSE;
    BOOL visible = FALSE;
    int xloc = 0;
    int count = 0;
    CCARRAY_FOREACH(enemiesOfType, enemy)
    {
        if(enemy.visible == NO)
        {
            count++;
        }
    }
    if(count <4)
    {
        count = 0;
    }
    // if the enemiesOfType array exists, iterate over all already existing enemies of the provided type and check if one of them can be respawned
    if (enemiesOfType != nil && count == 4)
    {
        NSLog(@"Spawn1");
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {

            // find the first free enemy and respawn it
            if (enemy.visible == YES)
            {
                visible = TRUE;

                // remember, that we will not need to create a new enemy

            }
        }
        if(visible == false)
        {
            CCARRAY_FOREACH(enemiesOfType, enemy)
            {
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width;
                CGFloat screenHeight = screenRect.size.height;
                [enemy spawn:screenHeight+xloc:100];
                xloc+=20;
            }
            xloc=0;
            
        }
        
    }
    else if(enemiesOfType==nil)
    {
    

                //NSLog(@"YEAP2");
        // if no enemies of that type existed yet, the enemiesOfType array will be nil and we first need to create one
        enemiesOfType = [[CCArray alloc] init];
        [enemies3 setObject:enemiesOfType forKey:(id<NSCopying>)[Coins class]];
    
        
    }
  
    // if we haven't been able to find a enemy to respawn, we need to create one
    if (!foundEnemy3)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;

            NSLog(@"Spawn2");
        // initialize an enemy of the provided class
        Coins*enemy =  [(Coins *) [[Coins class] alloc] initWithCoinImage];
        Coins*enemy2 =  [(Coins *) [[Coins class] alloc] initWithCoinImage];
        Coins*enemy3 =  [(Coins *) [[Coins class] alloc] initWithCoinImage];
        Coins*enemy4 =  [(Coins *) [[Coins class] alloc] initWithCoinImage];
        
        [enemy spawn:screenHeight +100 :100];
        [enemy2 spawn:screenHeight +120 :100];
        [enemy3 spawn:screenHeight +140 :100];
        [enemy4 spawn:screenHeight +160:100];

        [enemiesOfType addObject:enemy];
        [enemiesOfType addObject:enemy2];
        [enemiesOfType addObject:enemy3];
        [enemiesOfType addObject:enemy4];

        [batch3 addChild:enemy];
        [batch3 addChild:enemy2];
        [batch3 addChild:enemy3];
        [batch3 addChild:enemy4];
        foundEnemy3 = TRUE;
    }

}
 
-(void) spawnEnemyOfType:(Class)enemyTypeClass
{
    /* the 'enemies' dictionary stores an array of available enemies for each enemy type. 
     We use the class of the enemy as key for the dictionary, to receive an array of all existing enimies of that type.
     We use a CCArray since it has a better performance than an NSArray. */

        CCArray* enemiesOfType = [enemies objectForKey:enemyTypeClass];
    
    Ramps* enemy;
    Truth* data = [Truth sharedData];
    
    /* we try to reuse existing enimies, therefore we use this flag, to keep track if we found an enemy we can
     respawn or if we need to create a new one */
    BOOL foundAvailableEnemyToSpawn = FALSE;


    // if the enemiesOfType array exists, iterate over all already existing enemies of the provided type and check if one of them can be respawned
    //NSLog(onScreen ? @"Yes" : @"No");
    if (enemiesOfType != nil)
    {
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {
            if(enemy.visible==YES)
            {
                //NSLog(@"YEAP");
                onScreen = true;
            }
        }
 
        CCARRAY_FOREACH(enemiesOfType, enemy)
        {
            // find the first free enemy and respawn it
            if (enemy.visible == NO)
            {
                if(onScreen==false)
                {
                    //NSLog(@"YEAP2");
                    [enemy spawn:data.gainedDistance];
                }
                // remember, that we will not need to create a new enemy
                foundAvailableEnemyToSpawn = TRUE;
                break;
            }
        }
    }
    else
    {

        // if no enemies of that type existed yet, the enemiesOfType array will be nil and we first need to create one
        enemiesOfType = [[CCArray alloc] init];
        [enemies setObject:enemiesOfType forKey:(id<NSCopying>)enemyTypeClass];
    }
    //NSLog(onScreen ? @"Yes" : @"No");
    // if we haven't been able to find a enemy to respawn, we need to create one
    if (!foundEnemy1)
    {
        if(onScreen == false)
        {
           
             //NSLog(@"NOPE");
            // initialize an enemy of the provided class
            Ramps *enemy =  [(Ramps *) [enemyTypeClass alloc] initWithRampImage];
            //Box1 *enemy = [(Box1 *) [enemyTypeClass alloc] initWithBoxImage];
            [enemy spawn:data.gainedDistance];

            [enemiesOfType addObject:enemy];
                

            [batch addChild:enemy];
            foundEnemy1 = true;
             NSLog(@"done");
        }

    }
    //NSLog(@"NOPE");
    onScreen = false;
    
}

-(BOOL) checkForCollisions
{
    Ramps *ramp;
    Knight *knight = [[GameMechanics sharedGameMechanics] knight];

    
    CCARRAY_FOREACH([batch children], ramp)
    {
        [ramp detectCol:ccp(knight.position.x, knight.position.y)];
        if(ramp.col==true)
        {
            CGSize size = [ramp contentSize];
            CGPoint pos = ramp.position;
            Truth* data = [Truth sharedData];
            data.pos = pos;
            data.sprite = size;
            return true;
        }
    }
    return false;
    /*
    Knight *knight = [[GameMechanics sharedGameMechanics] knight];
    CGRect knightBoundingBox = [knight boundingBox];
    CGRect knightHitZone = [knight hitZone];
    //
    // iterate over all enemies (all child nodes of this enemy batch)
	CCARRAY_FOREACH([batch children], enemy)
	{
        // only check for collisions if the enemy is visible
		if (enemy.visible)
		{
			CGRect bbox = [enemy boundingBox];
            
             1) check collision between Bounding Box of the knight and Bounding Box of the enemy.
                If a collision occurs here, only the knight can kill the enemy. The knight can not be injured by this colission. The knight can only be injured if his hit zone collides with an enemy (checked in step 2) )
             
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
            
             2) now we check if the knights Hit Zone collided with the enemy. If this happens, and he is not stabbing, he will be injured.
             
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
	}*/
}
-(BOOL) checkForBoxCollisions
{
    Box1 *box;
    Knight *knight = [[GameMechanics sharedGameMechanics] knight];
    CCARRAY_FOREACH([batch2 children], box)
    {
        //NSLog(@"done");
        CGRect bbox = [box boundingBox];
        CGRect bbox2 = CGRectMake(CGRectGetMinX(bbox)+35,CGRectGetMinY(bbox), CGRectGetWidth(bbox)-35, CGRectGetHeight(bbox)+5);
        //CGRect bbox3 = CGRectMake(knight.position.x, knight.position.y, knight.height.x, knight.contentSize.y);
        CGRect knightBoundingBox = [knight boundingBox];
        CGRect knightHitZone = [knight hitZone];
        if (CGRectIntersectsRect(knightHitZone, bbox2))
        {
           // NSLog(@"done");
            return true;
        }
        else
        {
            return false;
        }

    }
    return false;
}
-(int) checkForCoinCollisions
{
    int counter = 0;
    BOOL hit = false;
    Coins *coin1;
    Knight *knight = [[GameMechanics sharedGameMechanics] knight];
    CCARRAY_FOREACH([batch3 children], coin1)
    {
        //NSLog(@"done");
        CGRect bbox = [coin1 boundingBox];
        //CGRect bbox2 = CGRectMake(CGRectGetMinX(bbox)+35,CGRectGetMinY(bbox), CGRectGetWidth(bbox)+10, CGRectGetHeight(bbox)+5);
        //CGRect bbox3 = CGRectMake(knight.position.x, knight.position.y, knight.height.x, knight.contentSize.y);
        CGRect knightBoundingBox = [knight boundingBox];
        CGRect knightHitZone = [knight hitZone];
        CGRect bbox2 = CGRectMake(CGRectGetMinX(knightHitZone),CGRectGetMinY(knightHitZone)+15, CGRectGetWidth(knightHitZone)-35, CGRectGetHeight(knightHitZone)-5);
        
        if (CGRectIntersectsRect(bbox2, bbox))
        {
            
            if(coin1.visible == YES)
            {
                coin1.visible = NO;
                counter++;
            }
        }
        
    }
    return counter;
}


-(void) update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        updateCount++;
        Truth* data = [Truth sharedData];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        // first we get all available monster types
        NSArray *monsterTypes = [[[GameMechanics sharedGameMechanics] spawnRatesByMonsterType] allKeys];
        CCArray* enemiesOfType = [enemies objectForKey:[Ramps class]];
        CCArray* enemiesOfType2 = [enemies2 objectForKey:[Box1 class]];
        CCArray* enemiesOfType3 = [enemies3 objectForKey:[Coins class]];
        Ramps* enemy;
        Box1* enemy2;
        Coins *enemy3;
        for (Class monsterTypeClass in monsterTypes)
        {
            // we get the spawn frequency for this specific monster type
            int spawnFrequency = [[GameMechanics sharedGameMechanics] spawnRateForMonsterType:monsterTypeClass];
            //NSLog(@"Value of hello = %f", updateCount*((1/delta)/60));
           //NSLog((data.gainedDistance % spawnFrequency == 1) ? @"Yes" : @"No");
            if(updateCount/((1/delta)/60) <= 900)
            {
                
            }
            //else
            //{
            // if the updateCount reached the spawnFrequency we spawn a new enemy
            if ((data.gainedDistance % spawnFrequency >= 0 && data.gainedDistance %spawnFrequency <= 10) )
            {
              
                spawned2 = true;
                if(monsterTypeClass == [Ramps class])
                {
                     
                    [self spawnEnemyOfType:[Ramps class]];
                    spawned2 = false;
                }
                else if(monsterTypeClass == [Coins class])
                {
                    BOOL same = FALSE;
                    if (enemiesOfType != nil)
                    {
                        
                        CCARRAY_FOREACH(enemiesOfType, enemy);
                        {
                            CGRect bbox = [enemy boundingBox];
                            CGRect spawned = CGRectMake(screenHeight+100, 20, 200, 300);
                            if(CGRectIntersectsRect(bbox, spawned))
                            {
                                same = true;
                            }
                            
                        }
                        CCARRAY_FOREACH(enemiesOfType2,enemy2);
                        {
                            if(enemy2.visible == YES)
                            {
                            CGRect bbox = [enemy2 boundingBox];
                            CGRect spawned = CGRectMake(screenHeight+100, 20, 200,300);
                            
                            if(CGRectIntersectsRect(bbox, spawned))
                            {
                                same = true;
                            }
                            }
                        }
                 
                        
                    }
                    if(same == FALSE)
                    {
                        //randomly spawn a set of coins
                        //NSLog(@"spawn");
                        [self spawnEnemyOfType3];
                        spawned2 = false;
                    }

                }
                else
                {
                    BOOL same2 = FALSE;
                    if (enemiesOfType != nil)
                    {
                        
                        CCARRAY_FOREACH(enemiesOfType, enemy);
                        {
                            if(enemy.visible == YES)
                            {
                            CGRect bbox = [enemy boundingBox];
                            CGRect spawned = CGRectMake(screenHeight + 100, 20, 120, 80);
                            if(CGRectIntersectsRect(bbox, spawned))
                            {
                                same2 = true;
                            }
                            }

                        }
                        
                    }
                if(same2 == FALSE)
                {
      
                    [self spawnEnemyOfType2];
                    spawned2 = false;
                }
                
                }
            }
        }
        
        
 
        if (enemiesOfType2 != nil || enemiesOfType !=nil || enemiesOfType3!=nil)
        {
            
            CCARRAY_FOREACH(enemiesOfType, enemy)
            {
                
                
                enemy.velocity = ccp(data.scrollSpeed, enemy.velocity.y);
                if(enemy.position.x < -400)
                {
                    enemy.visible = NO;
                }
            }
            CCARRAY_FOREACH(enemiesOfType2, enemy2)
            {
                //NSLog(@"success");
                if(enemy2.visible == YES)
                {
                    enemy2.velocity = ccp(data.scrollSpeed, enemy2.velocity.y);
                }
                if(enemy2.position.x<-100)
                {
                    enemy2.visible =NO;
                }
            }
            
            CCARRAY_FOREACH(enemiesOfType3, enemy3)
            {
                
                if(enemy3.visible == YES)
                {
                    //NSLog(@"spawn2");
                    enemy3.velocity = ccp(data.scrollSpeed, enemy3.velocity.y);
                }
                if(enemy3.position.x<-100)
                {
                    enemy3.visible =NO;
                }
            }
            if([self checkForCollisions])
            {
                data.onRamp = true;
            }	
            else
            {
                data.onRamp=false;
            }
        }
        if([self checkForBoxCollisions] == TRUE)
        {
            //NSLog(@"hit");
            data.hit = [self checkForBoxCollisions];
        }
        else
        {
            data.hit = false;
        }
        data.collect = [self checkForCoinCollisions];
   // }
    }
}

@end
