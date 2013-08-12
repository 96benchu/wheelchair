//
//  Box2.m
//  Wheelchair
//
//  Created by Ben on 31/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Box2.h"
#import "GameMechanics.h"

@implementation Box2
@synthesize velocity;
-(id)initWithBox2Image
{
    self = [super initWithSpriteFrameName:@"spike.png"];
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
	self.position = CGPointMake(screenHeight +100, 0);
	self.rotation = 15;
    self.scaleX = .9;
    self.scaleY = .5;
    self.velocity = ccp(00, 0);
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
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
