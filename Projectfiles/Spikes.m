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

-(id)initWithSpikeImage
{
    self = [super initWithFile:@"spike.png"];
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
    
       

}



@end
