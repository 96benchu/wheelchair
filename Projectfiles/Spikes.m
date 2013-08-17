//
//  Spikes.m
//  Wheelchair
//
//  Created by Ben on 25/06/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Spikes.h"
#import "GameMechanics.h"
@implementation Spikes
@synthesize velocity;
- (void)dealloc
{
    /*
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(id)initWithSpikeImage
{
    self = [super initWithFile:@"spike.png"];
    self.velocity = ccp(0,0);
    
    [self scheduleUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
    return self;
    
}
- (void)gamePaused
{
    [self pauseSchedulerAndActions];
}

- (void)gameResumed
{
    [self resumeSchedulerAndActions];
}

- (void)update:(ccTime)delta
{
    // only execute the block, if the game is in 'running' mode

        [self updateRunningMode:delta];

}


- (void)updateRunningMode:(ccTime)delta
{

    
    [self setPosition:ccpAdd(self.position, ccpMult(self.velocity,delta))];
    
       

}



@end
