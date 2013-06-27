//
//  RunDistanceMission.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/12/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "RunDistanceMission.h"

@implementation RunDistanceMission

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.missionObjectives = [[NSMutableArray alloc] init];

        // available mission objectives need to be defined here, for mission generator
        runningDistance = [[MissionObjective alloc] initWithObjectiveType:MissionObjectiveTypeHigherIsBetter];
        [self.missionObjectives addObject:runningDistance];
        // the goal value will be set later on, either manually or by the mission generator
    }
    
    return self;
}

/*
 Here we need to restore any information, that is not persisted and loaded in the Superclass 'Mission'.
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    // call the superclass, that initializes a mission from disk
    self = [super initWithCoder:decoder];
    // additionally store a reference to the 'runningDistance' objective in the instance variable.
    runningDistance = [self.missionObjectives objectAtIndex:0];
    
    return self;
}

- (void)missionStart:(Game *)game
{
    // capture the start distance
    startDistance = game.meters;
}

- (void)generalGameUpdate:(Game *)game
{
    // check if we have reached the required distance
    if ((game.meters - startDistance) > runningDistance.goalValue)
    {
        self.successfullyCompleted = TRUE;
    }
}

@end
