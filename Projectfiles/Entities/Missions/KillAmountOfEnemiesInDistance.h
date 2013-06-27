//
//  KillAmountOfEnemiesInDistance.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Mission.h"
#import "MissionObjective.h"

@interface KillAmountOfEnemiesInDistance : Mission
{
    // the current amount of killed enemies, when the mission started. Used to compare, how far the player has run since the mission start.
    int startAmountKilledEnemies;
    int startDistance;
    
    MissionObjective *killAmountOfEnemies;
    MissionObjective *withinDistance;
}

- (void)generalGameUpdate:(Game *)game;

@end
