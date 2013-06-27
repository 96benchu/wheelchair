//
//  GhostMonster.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "BasicMonster.h"
#import "GameMechanics.h"

@implementation BasicMonster

- (id)initWithMonsterPicture
{
    self = [super initWithSpriteFrameName:@"monster1_1.png"];
    
    if (self)
    {
        self.initialHitPoints = 1;
		self.velocity = CGPointMake(-30, 0);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"monster-animations.plist"];
        
        self.animationFrames = [NSMutableArray array];
        
        for(int i = 1; i <= 5; ++i)
        {
            [self.animationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"monster1_%d.png", i]]];
        }
        
        //Create an animation from the set of frames you created earlier
        CCAnimation *running = [CCAnimation animationWithSpriteFrames: self.animationFrames delay:0.2f];
        
        //Create an action with the animation that can then be assigned to a sprite
        self.run = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:running]];
        
        // run the animation
        [self runAction:self.run];
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)spawn
{
	// Select a spawn location just outside the right side of the screen, with random y position
	CGRect screenRect = [[CCDirector sharedDirector] screenRect];
	CGSize spriteSize = [self contentSize];
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = CCRANDOM_0_1() * (0.25 * screenRect.size.height - spriteSize.height) + spriteSize.height * 0.5f;
	self.position = CGPointMake(xPos, yPos);
	
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
	
	// reset health
	self.hitPoints = self.initialHitPoints;
}

- (void)gotHit {
    
    CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
    
    // Set some parameters that can't be set in Particle Designer
    system.positionType = kCCPositionTypeFree;
    system.autoRemoveOnFinish = YES;
    system.position = self.position;
    
    // Add the particle effect to the GameScene, for these reasons:
    // - self is a sprite added to a spritebatch and will only allow CCSprite nodes (it crashes if you try)
    // - self is now invisible which might affect rendering of the particle effect
    // - since the particle effects are short lived, there is no harm done by adding them directly to the GameScene
    [[[GameMechanics sharedGameMechanics] gameScene] addChild:system];
    
    CCSprite *coinSprite = [CCSprite spriteWithFile:@"coin.png"];
    coinSprite.position = self.position;
    [[[GameMechanics sharedGameMechanics] gameScene] addChild:coinSprite];
    CGSize screenSize = [[GameMechanics sharedGameMechanics] gameScene].contentSize;
    CGPoint coinDestination = ccp(21, screenSize.height-27);
    CCMoveTo *move = [CCMoveTo actionWithDuration:2.f position:coinDestination];
    id easeMove = [CCEaseBackInOut actionWithAction:move];
    
    CCAction *movementCompleted = [CCCallBlock actionWithBlock:^{
        // this code is called when the movement is completed, then we we want to clean up the coinSprite
        coinSprite.visible = FALSE;
        [coinSprite removeFromParent];
        coinSprite.zOrder = MAX_INT -1;
    }];
    
    CCSequence *coinMovementSequence = [CCSequence actions:easeMove, movementCompleted, nil];
    
    [coinSprite runAction: coinMovementSequence];
    
    // mark as unvisible and move off screen
    self.visible = FALSE;
    self.position = ccp(-MAX_INT, 0);
    [[GameMechanics sharedGameMechanics] game].enemiesKilled += 1;
    [[GameMechanics sharedGameMechanics] game].score += 50;
}

- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        [self updateRunningMode:delta];
    }
}

- (void)updateRunningMode:(ccTime)delta
{
    // apply background scroll speed
    float xVelocity = self.velocity.x;
    float backgroundScrollSpeedX = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
    
    xVelocity -= backgroundScrollSpeedX;
    CGPoint combinedVelocity = ccp(xVelocity, self.velocity.y);
    
    
    // move the monster until it leaves the left edge of the screen
    if (self.position.x > (self.contentSize.width * (-1)))
    {
        [self setPosition:ccpAdd(self.position, ccpMult(combinedVelocity,delta))];
    }
}

@end
