//
//  Mission.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Mission.h"
#import "MissionObjective.h"

@implementation Mission

@synthesize successfullyCompleted, missionObjectives, scoreBonus, missionDescriptionFormat, thumbnailFileName;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.successfullyCompleted = FALSE;
    }
    
    return self;
}

/*
 This method is used to store the Mission to disk.
 You will not have to modify this.
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self) {
        self.successfullyCompleted = [decoder decodeBoolForKey:@"successfullyCompleted"];
        self.missionObjectives = [decoder decodeObjectForKey:@"missionObjectives"];
        self.scoreBonus = [decoder decodeIntegerForKey:@"scoreBonus"];
        self.missionDescriptionFormat = [decoder decodeObjectForKey:@"missionDescriptionFormat"];
        self.thumbnailFileName = [decoder decodeObjectForKey:@"thumbnailFileName"];
    }
    
    return self;
}

/*
 This method is used to read a store Mission from disk.
 You will not have to modify this.
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeBool:self.successfullyCompleted forKey:@"successfullyCompleted"];
    [encoder encodeObject:self.missionObjectives forKey:@"missionObjectives"];
    [encoder encodeInt:self.scoreBonus forKey:@"scoreBonus"];
    [encoder encodeObject:self.missionDescriptionFormat forKey:@"missionDescriptionFormat"];
    [encoder encodeObject:self.thumbnailFileName forKey:@"thumbnailFileName"];
}

- (void)missionStart:(Game *)game
{
    // needs to be implemented by subclass
    @throw @"Needs to be implemented in subclass";
}

/*
 The missionDescription is built with the provided FormatString and the goalValues of the different objectives.
 Currently only two objectives per mission are supported.
 */
- (NSString *)missionDescription
{
    // currently only two objectives are supported
    NSAssert([self.missionObjectives count] <= 2, @"more than two objectives per mission not supported");
    NSString *returnValue = nil;
    
    if ([self.missionObjectives count] == 1)
    {
        // description for missions with one objective
        int goalValue1 = [[self.missionObjectives objectAtIndex:0] goalValue];
        returnValue = [NSString stringWithFormat:self.missionDescriptionFormat, goalValue1];
    } else if ([self.missionObjectives count] == 2)
    {
        // description for missions with two objectives
        int goalValue1 = [[self.missionObjectives objectAtIndex:0] goalValue];
        int goalValue2 = [[self.missionObjectives objectAtIndex:1] goalValue];
        returnValue = [NSString stringWithFormat:self.missionDescriptionFormat, goalValue1, goalValue2];
    }
    
    return returnValue;
}

@end
