//
//  Game.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Game.h"
#import "Mission.h"
#import "RunDistanceMission.h"
#import "KillAmountOfEnemiesMission.h"
#import "MissionObjective.h"
#import "MissionProvider.h"

// key to persist players progress in the keychain
#define MISSION_STATUS_KEY @"MissionStatus"

// store the current missions in a class variable, since they shall be persistent and independent of a single game session
static NSMutableArray *_missions;
static NSArray *_allMissions;

@interface Game()

// lets the game load missions
+ (void)loadMissions;

// lets the game persist mission
+ (void)persistMissions;

@end

@implementation Game

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (self.missions == nil)
        {
            [Game loadMissions];
        }
    }
    
    return self;
}

- (void)replaceCompletedMission
{
    for (unsigned int j =0; j < [self.missions count]; j++)
    {
        Mission *mission = [self.missions objectAtIndex:j];
        
        if (mission.successfullyCompleted)
        {
            Mission *newMission = nil;
            
            // first try to find, if there are manually defined mission left over
            // we first detect the position of the current mission in the 'allMissions' list. We only want to look for missions that come after this one
            unsigned int startSearchIndex = [self.allMissions indexOfObject:mission];
            
            for (unsigned int i = startSearchIndex; i < [self.allMissions count]; i++)
            {
                Mission *m = [self.allMissions objectAtIndex:i];
                
                // check that mission is not completed, and not used as an active mission currently
                if (!m.successfullyCompleted && ([self.missions indexOfObject:m] == NSNotFound))
                {
                    // if we found a mission, that comes after the one that should be replaced, and is not yet completed, we use that mission as newMission
                    newMission = m;
                }
            }
            
            if (newMission == nil)
            {
                newMission = [MissionProvider generateNewMission];
            }
            
            // replace mission with new one
            int replacementIndex = [self.missions indexOfObject:mission];
            [self.missions replaceObjectAtIndex:replacementIndex withObject:newMission];
        }
    }
    
    [Game persistMissions];
}

+ (void)loadMissions
{
    _allMissions = [MissionProvider allMissions];
    
    _missions = [[NSMutableArray alloc] init];
    
    NSArray *missionIndexes = [[NSUserDefaults standardUserDefaults] objectForKey:MISSION_STATUS_KEY];
    
    if ([missionIndexes count] < 3)
    {
        // if no indexes are stored, start with the first three missions
        _missions = [@[ [_allMissions objectAtIndex:0], [_allMissions objectAtIndex:1], [_allMissions objectAtIndex:2]] mutableCopy];
    } else
    {
        // if we have mission indexes, add these missions as current missions
        for (NSNumber *missionIndex in missionIndexes)
        {
            
            if ([missionIndex intValue] == NSNotFound)
            {
                @throw @"Error in loading persisted missions";
            } else
            {
                int i = [missionIndex intValue];
                [_missions addObject:[_allMissions objectAtIndex:i]];
            }
        }
    }
}

+ (void)persistMissions
{
    /* store the indexes of the currently active missions (within the allMissionsArray) in an array, to be able to reload this missions on game restart. Generated missions will be entered with an NSNotFound index and generated new on demand. */
    NSMutableArray *indexesOfActiveMissions = [[NSMutableArray alloc] init];

    for (unsigned int i = 0; i < [_missions count]; i++)
    {
        Mission *m = [_missions objectAtIndex:i];
        int indexOfMission = [_allMissions indexOfObject:m];
        NSNumber *indexOfMissionNr = [NSNumber numberWithInt:indexOfMission];
        [indexesOfActiveMissions addObject:indexOfMissionNr];
    }

    [[NSUserDefaults standardUserDefaults] setObject:indexesOfActiveMissions forKey:MISSION_STATUS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Setter/Getter overriding

- (void)setMissions:(NSMutableArray *)missions
{
    _missions = missions;
}

- (NSMutableArray *)missions
{
    return _missions;
}

- (void)setAllMissions:(NSMutableArray *)allMissions
{
    _allMissions = allMissions;
}

- (NSArray *)allMissions
{
    return _allMissions;
}

@end
