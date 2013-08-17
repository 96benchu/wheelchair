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
- (void)dealloc
{
    /*
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(id)initWithRampImage
{
    self = [super initWithSpriteFrameName:@"ramp.png"];
    self.velocity = ccp(0,0);
    [self scheduleUpdate];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
    return self;
    
}

- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode
    
    [self updateRunningMode:delta];
    
}
- (void)gamePaused
{
    [self pauseSchedulerAndActions];
}

- (void)gameResumed
{
    [self resumeSchedulerAndActions];
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
    CGRect bbox2 = CGRectMake(CGRectGetMinX(bbox),CGRectGetMinY(bbox), CGRectGetWidth(bbox)-20, CGRectGetHeight(bbox));
    if(CGRectContainsPoint(bbox2, pos))
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
    float scaled2;
    NSLog(@"Value of hello = %i", data.gainedDistance);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
	CGSize spriteSize = [self contentSize];
    self.anchorPoint = ccp(0,0);
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = 20;
	self.position = CGPointMake(screenHeight+100, 20);
    double rand3 = arc4random()%5;
    double rand;
    double rand2;
    if(data.gainedDistance<500)
    {
        scaled = .90;
        scaled2 = .9;
    }
    else if(data.gainedDistance>=500 && data.gainedDistance<=1200)
    {
        
         rand = arc4random()%1;
        scaled = 1.025;
        scaled2= 1.025;
    }
    else if(data.gainedDistance>=1201 && data.gainedDistance<=2000)
    {
        if(rand3==1 || rand3== 3)
        {
        rand = arc4random()%6+46;
        rand2 = arc4random()%6+46;

        scaled = rand/40;
        scaled2 = rand2/40;
        }
        else if(rand3==2)
        {
         rand = arc4random()%6+50;
         rand2 = 42-arc4random()%6;
         
         scaled = rand/40;
         scaled2 = rand2/40;
         }
        else
        {
            rand2 = arc4random()%6+50;
            rand = 40-arc4random()%6;
            
            scaled = rand/40;
            scaled2 = rand2/40;
        }
    }
    else if(data.gainedDistance>=2001&& data.gainedDistance<=3000)
    {
        if(rand3==1 || rand3== 3)
        {
        rand = arc4random()%8+56;
        rand2 = arc4random()%8+56;
        
        scaled = rand/40;
        scaled2 = rand2/40;
        }
        else if(rand3==2)
        {
            rand = arc4random()%8+60;
            rand2 = 48-arc4random()%8;
            
            scaled = rand/40;
            scaled2 = rand2/40;
        }
        else
        {
            rand2 = arc4random()%8+60;
            rand = 52-arc4random()%8;
            
            scaled = rand/40;
            scaled2 = rand2/40;
        }
    }
    else
    {
        if(rand3==1 || rand3== 3)
        {
        rand = arc4random()%10+66;
        rand2 = arc4random()%10+66;
        
        scaled = rand/40;
        scaled2 = rand2/40;
        }
        else if(rand3==2)
        {
            rand = arc4random()%6+70;
            rand2 = 54-arc4random()%6;
            
            scaled = rand/40;
            scaled2 = rand2/40;
        }
        else
        {
            rand2 = arc4random()%6+70;
            rand = 58-arc4random()%6;
            
            scaled = rand/40;
            scaled2 = rand2/40;
        }
        
    }
    
	self.scaleX = scaled;
    self.scaleY = scaled2;
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
}

@end
