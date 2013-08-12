//
//  Ramps.m
//  Wheelchair
//
//  Created by Ben on 27/06/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Ramps.h"
#import "GameMechanics.h"
#import "Truth.h"
@implementation Ramps
@synthesize velocity;

-(id)initWithRampImage
{
    self = [super initWithSpriteFrameName:@"ramp.png"];
    self.velocity = ccp(0,0);
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
    Truth *data = [Truth sharedData];
	// Select a spawn location just outside the right side of the screen, with random y position
	//CGRect screenRect = [[CCDirector sharedDirector] screenRect];
    float scaled;
    NSLog(@"Value of hello = %i", data.gainedDistance);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
	CGSize spriteSize = [self contentSize];
    self.anchorPoint = ccp(0,0);
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = 20;
	self.position = CGPointMake(screenHeight+100, 20);
    if(data.gainedDistance<500)
    {
        scaled = .90;
    }
    else if(data.gainedDistance>=750 && data.gainedDistance<=1200)
    {
        
        double rand = arc4random()%1;
        scaled = 20/20;
    }
    else if(data.gainedDistance>=1200 && data.gainedDistance<=2000)
    {
        double rand = arc4random()%1+22;
        scaled = rand/20;
    }
    else if(data.gainedDistance>=2000 && data.gainedDistance<=3000)
    {
        NSLog(@"itisdone");
        double rand = arc4random()%1+24;
        scaled = rand/20;
    }
    else
    {
        double rand = arc4random()%1+28;
        scaled = rand/20;
    }
    
	self.scale = scaled;
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
}

@end
