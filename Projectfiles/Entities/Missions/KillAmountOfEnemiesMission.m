//
//  KillAmountOfEnemiesMission.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "KillAmountOfEnemiesMission.h"

@implementation KillAmountOfEnemiesMission

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.missionObjectives = [[NSMutableArray alloc] init];
        
        // available mission objectives need to be defined here, for mission generator
        killAmountOfEnemies = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeHigherIsBetter];
        [self.missionObjectives addObject:killAmountOfEnemies];
        // the goal value will be set later on, either manually or by the mission generator
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    // call the superclass, that initializes a mission from disk
    self = [super initWithCoder:decoder];
    // additionally store a reference to the 'killAmountOfEnemies' objective in the instance variable.
    killAmountOfEnemies = [self.missionObjectives objectAtIndex:0];
    
    return self;
}

- (void)missionStart:(Game *)game
{
    // capture the start distance
    startAmountKilledEnemies = game.enemiesKilled;
}

- (void)generalGameUpdate:(Game *)game
{
    // check if we have reached the required distance
    if ((game.enemiesKilled - startAmountKilledEnemies) >= [killAmountOfEnemies goalValue])
    {
        self.successfullyCompleted = TRUE;
    }
}

@end
