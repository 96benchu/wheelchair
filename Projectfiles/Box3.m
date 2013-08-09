//
//  Box3.m
//  Wheelchair
//
//  Created by Ben on 31/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Box3.h"

@implementation Box3
@synthesize velocity;
-(id)initWithBox3Image
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
	self.position = CGPointMake(screenHeight +100, 85);
	self.rotation = 90;
    self.scaleX = .45;
    self.scaleY = .3;
    self.velocity = ccp(-0, 0);
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