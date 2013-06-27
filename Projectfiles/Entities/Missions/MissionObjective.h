//
//  MissionObjective.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

/* define the different possible mission count types, by using constants.
 This type is used by the mission generator to generate different missions, for example:
 - run 100 meters
 - run 200 meters
 
 - avoid enemies for 10 seconds
 - avoid enemies for 20 seconds
 
 To know, what is more difficult, the mission generator needs to know, if a high or a low score are better.
 */
typedef NS_ENUM(NSInteger, MissionObjectiveType) {
    MissionObjectiveTypeHigherIsBetter,
    MissionObjectiveTypeLowerIsBetter
};

@interface MissionObjective : NSObject <NSCoding>

- (id)initWithObjectiveType:(MissionObjectiveType)objectiveType goalValue:(int)goalValue;

- (id)initWithObjectiveType:(MissionObjectiveType)objectiveType;

// defines if a lower score, or a higher score is better for this objective
@property (nonatomic, assign) MissionObjectiveType objectiveType;

// defines the goal value
@property (nonatomic, assign) int goalValue;

@end
