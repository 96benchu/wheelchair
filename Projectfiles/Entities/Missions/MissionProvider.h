//
//  MissionProvider.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>
#import "Mission.h"

@interface MissionProvider : NSObject

+ (NSArray *)allMissions;
+ (Mission *)generateNewMission;
// is used by the mission generator
+ (Mission *)generateMissionWithMission:(Mission *)mission;

@end
