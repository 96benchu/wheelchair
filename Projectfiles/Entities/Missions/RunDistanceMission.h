//
//  RunDistanceMission.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/12/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Mission.h"
#import "MissionObjective.h"
/**
 A mission type, that requires the player to run a certain distance for fulfilling it.
 **/

@interface RunDistanceMission : Mission
{
    // the current distance, when the mission started. Used to compare, how far the player has run since the mission start.
    int startDistance;
    
    MissionObjective *runningDistance;
}

- (void)generalGameUpdate:(Game *)game;

@end
