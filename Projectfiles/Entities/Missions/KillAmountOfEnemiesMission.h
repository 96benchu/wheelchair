//
//  KillAmountOfEnemiesMission.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Mission.h"
#import "MissionObjective.h"

/**
 A mission type, that requires the player to kill a certain amount of enemies.
 **/

@interface KillAmountOfEnemiesMission : Mission
{
    // the current amount of killed enemies, when the mission started. Used to compare, how far the player has run since the mission start.
    int startAmountKilledEnemies;
    
    MissionObjective *killAmountOfEnemies;
}

- (void)generalGameUpdate:(Game *)game;

@end
