//
//  SlowMonster.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/18/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "SlowMonster.h"
#import "GameMechanics.h"

@implementation SlowMonster

- (id)initWithMonsterPicture
{
    self = [super initWithSpriteFrameName:@"monster2_1.png"];
    
    if (self)
    {
        self.initialHitPoints = 1;
		self.velocity = CGPointMake(-10, 0);
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"monster-animations.plist"];
        
        self.animationFrames = [NSMutableArray array];
        
        for(int i = 1; i <= 3; ++i)
        {
            [self.animationFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"monster2_%d.png", i]]];
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
        // cleanup
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
    [[GameMechanics sharedGameMechanics] game].score += 1;
}

@end
