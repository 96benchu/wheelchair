//
//  MissionObjective.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "MissionObjective.h"

@implementation MissionObjective

- (id)initWithObjectiveType:(MissionObjectiveType)objectiveType goalValue:(int)goalValue
{
    self = [super init];
    
    if (self)
    {
        self.objectiveType = objectiveType;
        self.goalValue = goalValue;
    }
    
    return self;
}

- (id)initWithObjectiveType:(MissionObjectiveType)objectiveType
{
    self = [self initWithObjectiveType:objectiveType goalValue:0];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self) {
        self.objectiveType = [decoder decodeIntForKey:@"objectiveType"];
        self.goalValue = [decoder decodeIntForKey:@"goalValue"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:self.objectiveType forKey:@"objectiveType"];
    [encoder encodeInt:self.goalValue forKey:@"goalValue"];
}

@end
