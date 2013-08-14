//
//  Box1.m
//  Wheelchair
//
//  Created by Ben on 09/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Box1.h"
#import "GameMechanics.h"
@implementation Box1
@synthesize velocity;

-(id)initWithBoxImage
{
    self = [super initWithSpriteFrameName:@"basicbarrell.png"];
    [self scheduleUpdate];
    
    return self;
}
- (void)spawn
{
    
	// Select a spawn location just outside the right side of the screen, with random y position
	//CGRect screenRect = [[CCDirector sharedDirector] screenRect];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
	CGSize spriteSize = [self contentSize];
    self.anchorPoint = ccp(0,0);
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = 100;
	self.position = CGPointMake(screenHeight +100, 75);
	self.rotation = 90;
    self.scale = .3;
    self.velocity = ccp(-100, 0);
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
}
-(void) gotStolen
{
    
    
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
    /*
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
     [[GameMechanics sharedGameMechanics] game].score += 50;
     */
}

- (void)updateRunningMode:(ccTime)delta
{
    
    
    [self setPosition:ccpAdd(self.position, ccpMult(self.velocity,delta))];
    if(self.position.x < -100)
    {
        self.visible = false;
    }
}
- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    
    [self updateRunningMode:delta];
    
}
@end
