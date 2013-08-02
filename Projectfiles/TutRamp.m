//
//  TutRamp.m
//  Wheelchair
//
//  Created by Ben on 29/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "TutRamp.h"

@implementation TutRamp
@synthesize velocity;

-(id)initWithRampImage
{
    self = [super initWithFile:@"ramp.png"];
    self.velocity = ccp(0,0);
    self.visible = NO;
    [self scheduleUpdate];
    
    return self;
}

- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    
    [self updateRunningMode:delta];
    
}


- (void)updateRunningMode:(ccTime)delta
{
    
    
    [self setPosition:ccpAdd(self.position, ccpMult(self.velocity,delta))];
    if(self.position.x < -500)
    {
        self.visible = false;
    }
}

-(void)detectCol:(CGPoint)pos
{
    CGRect bbox = [self boundingBox];
    if(CGRectContainsPoint(bbox, pos))
    {
        self.col = true;
    }
    else
    {
        self.col = false;
    }
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
	float yPos = 20;
	self.position = CGPointMake(screenHeight+100, 20);
	self.scale = 1.2;
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
}

@end
