//
//  Ramps.m
//  Wheelchair
//
//  Created by Ben on 27/06/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Ramps.h"
#import "GameMechanics.h"
@implementation Ramps
@synthesize velocity;

-(id)initWithRampImage
{
    self = [super initWithFile:@"ramp.png"];
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
