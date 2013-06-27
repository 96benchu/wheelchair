//
//  KillAmountOfEnemiesInDistance.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "KillAmountOfEnemiesInDistance.h"
#import "MissionObjective.h"

@implementation KillAmountOfEnemiesInDistance

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.missionObjectives = [[NSMutableArray alloc] init];
        
        // available mission objectives need to be defined here, for mission generator
        killAmountOfEnemies = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeHigherIsBetter];
        [self.missionObjectives addObject:killAmountOfEnemies];
        
        withinDistance = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeLowerIsBetter];
        [self.missionObjectives addObject:withinDistance];
        // the goal value will be set later on, either manually or by the mission generator
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    // call the superclass, that initializes a mission from disk
    self = [super initWithCoder:decoder];
    // additionally store references to the 'killAmountOfEnemies' and 'withinDistance' objectives in the instance variable.
    killAmountOfEnemies = [self.missionObjectives objectAtIndex:0];
    withinDistance = [self.missionObjectives objectAtIndex:1];
    
    return self;
}

- (void)missionStart:(Game *)game
{
    // capture the start distance
    startAmountKilledEnemies = game.enemiesKilled;
    startDistance = game.meters;
}

- (void)generalGameUpdate:(Game *)game
{
    if ((game.meters - startDistance) > [withinDistance goalValue])
    {
        // the distance in within the goal should have been reached is over, mission has to be restarted
        [self missionStart:game];
        return;
    }
    
    // check if we have reached the required distance
    if ((game.enemiesKilled - startAmountKilledEnemies) >= [killAmountOfEnemies goalValue])
    {
        self.successfullyCompleted = TRUE;
    }
}

@end
