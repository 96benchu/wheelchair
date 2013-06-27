//
//  MissionProvider.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "MissionProvider.h"
#import "RunDistanceMission.h"
#import "KillAmountOfEnemiesMission.h"
#import "KillAmountOfEnemiesInDistance.h"

#define ALL_MISSIONS_KEY @"allMissions"

static NSMutableArray *missions;

@implementation MissionProvider

+ (void)loadMissions
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ALL_MISSIONS_KEY];
    missions = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (missions == nil)
    {
        missions = [[NSMutableArray alloc] init];
        
        RunDistanceMission *mission1 = [[RunDistanceMission alloc] init];
        mission1.missionDescriptionFormat = @"Run %d meters";
        mission1.thumbnailFileName = @"missions_1.png";
        [[mission1.missionObjectives objectAtIndex:0] setGoalValue:50];
        [self storeLastObjectiveGoalValuesForMission:mission1];
        
        KillAmountOfEnemiesMission *mission2 = [[KillAmountOfEnemiesMission alloc] init];
        mission2.missionDescriptionFormat = @"Kill %d enemies";
        mission2.thumbnailFileName = @"missions_2.png";
        [[mission2.missionObjectives objectAtIndex:0] setGoalValue:1];
        [self storeLastObjectiveGoalValuesForMission:mission2];
        
        KillAmountOfEnemiesInDistance *mission3 = [[KillAmountOfEnemiesInDistance alloc] init];
        mission3.missionDescriptionFormat = @"Kill %d enemies in %d meters";
        mission3.thumbnailFileName = @"missions_1.png";
        [[mission3.missionObjectives objectAtIndex:0] setGoalValue:2];
        [[mission3.missionObjectives objectAtIndex:1] setGoalValue:1500];
        [self storeLastObjectiveGoalValuesForMission:mission3];
        
        RunDistanceMission *mission4 = [[RunDistanceMission alloc] init];
        mission4.missionDescriptionFormat = @"Run %d meters";
        mission4.thumbnailFileName = @"missions_1.png";
        [[mission4.missionObjectives objectAtIndex:0] setGoalValue:150];
        [self storeLastObjectiveGoalValuesForMission:mission4];
        
        [missions addObjectsFromArray:@[mission1, mission2, mission3, mission4]];
        [self persistMissions];
    }
}

+ (void)persistMissions
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:missions];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:ALL_MISSIONS_KEY];
}

+ (NSArray *)allMissions
{
    if (missions == nil)
    {
        [MissionProvider loadMissions];
    }
    
    return missions;
}

+ (Mission *)generateNewMission
{
    // if we could not find a user defined mission, we need to generate one.

    // 1) pick one of the existing missions, choose from all previous mission
    int index = arc4random_uniform([missions count]);
    Mission *newMission = [MissionProvider generateMissionWithMission:[missions objectAtIndex:index]];
    newMission.successfullyCompleted = FALSE;
    
    NSArray *lastObjectives = [MissionProvider lastObjectivesGoalValuesForMission:newMission];
    
    for (unsigned int i = 0; i < [lastObjectives count]; i++)
    {
        MissionObjective *objective = [lastObjectives objectAtIndex:i];
        int lastGoalValue = [objective goalValue];
        
        if (objective.objectiveType == MissionObjectiveTypeHigherIsBetter)
        {
            int newGoalValue = lastGoalValue * 1.1;
            
            if (newGoalValue == lastGoalValue)
            {
                newGoalValue += 1;
            }
            
            [[[newMission missionObjectives] objectAtIndex:i] setGoalValue:newGoalValue];
        } else if (objective.objectiveType == MissionObjectiveTypeLowerIsBetter)
        {
            int newGoalValue = lastGoalValue / 1.1;
            [[[newMission missionObjectives] objectAtIndex:i] setGoalValue:newGoalValue];
            
            if (newGoalValue == lastGoalValue)
            {
                newGoalValue -= 1;
            }
        }
    }
    
    [self storeLastObjectiveGoalValuesForMission:newMission];
    
    [missions addObject:newMission];
    [MissionProvider persistMissions];
    
    return newMission;
}

+ (void)storeLastObjectiveGoalValuesForMission:(Mission *)mission
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[mission missionObjectives]];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:NSStringFromClass([mission class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)lastObjectivesGoalValuesForMission:(Mission *)mission
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromClass([mission class])];
    NSArray *lastObjectives = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return lastObjectives;
}


+ (Mission *)generateMissionWithMission:(Mission *)mission;
{
    Mission *newMission = [[[mission class] alloc] init];
    newMission.missionDescriptionFormat = mission.missionDescriptionFormat;
    newMission.thumbnailFileName = mission.thumbnailFileName;
    newMission.scoreBonus = mission.scoreBonus;
        
    return newMission;
}

@end
