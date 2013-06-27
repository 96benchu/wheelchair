//
//  Mission.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>
#import "Game.h"

@class Mission;

/* 
 Defines all methods, that missions can listen to, to get informed about the game state.
 Missions use these methods, to check if they are fulfilled.
 */
@protocol MissionProtocol <NSObject, NSCoding>

// indicates if the mission is successfuly completed. 
@property (nonatomic, assign) BOOL successfullyCompleted;

// stores a list of 'MissionObjectives'
@property (nonatomic, strong) NSMutableArray *missionObjectives;

// defines the bonus to the score, the player receives, when the mission is completed successfully
@property (nonatomic, assign) int scoreBonus;

// description that will be displayed within the game
@property (nonatomic, strong) NSString *missionDescriptionFormat;

// this mission description will be displayed. It is generade using the missionDescriptionFormat and the goal values of the different objectives
@property (nonatomic, readonly) NSString *missionDescription;

// image that will be displayed with the mission's description
@property (nonatomic, strong) NSString *thumbnailFileName;

// called when the mission is started, here the mission can capture the initial game state
- (void)missionStart:(Game *)game;

@optional

// provides the class with the killed monster
// another example, for a method that could be implemented, to inform missions about game events:
//- (void)monsterKilled:(Class)monsterClass;

// called in a certain frequency, allows the mission to access the parameters it needs (e.g. running distance).
- (void)generalGameUpdate:(Game *)game;

@end


/**
 Represents a mission the player has to fullfill.
 */
@interface Mission : NSObject <MissionProtocol>


@end
