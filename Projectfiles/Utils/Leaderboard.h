//
//  Leaderboard.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>

/**
 This class abstracts the leaderboard. It allows accessing the global leaderbord and the friends leaderboard.
 It uses the MGWU SDK internally.
 */

#define HIGHSCORE_LEADERBOARD @"defaultLeaderboard"
#define DISTANCE_LEADERBOARD @"distanceLeaderboard"

@interface Leaderboard : NSObject

+ (NSArray *)globalLeaderBoardEntries;
+ (NSArray *)friendsLeaderBoardEntries;
+ (int)personalRecordRunningDistance;
+ (void)setPersonalRecordRunningDistance:(int)personalRecordRunningDistance;
+ (NSString *)userName;
+ (void)setUserName:(NSString *)userName;

@end
