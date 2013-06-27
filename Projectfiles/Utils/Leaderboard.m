//
//  Leaderboard.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Leaderboard.h"
#import "GameMechanics.h"
#import "Game.h"

#define PERSONAL_RECORD_RUNNING_DISTANCE_KEY @"Running_Record"
#define USERNAME_KEY @"UserName"

@implementation Leaderboard

+ (void)setUserName:(NSString *)userName
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:USERNAME_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userName
{
    // first try using the facebook name, if unavailable, use the locally stored name
    NSString *userName = [MGWU getUsername];
    
    if (userName == nil)
    {
        userName = [[NSUserDefaults standardUserDefaults] objectForKey:USERNAME_KEY];
    }
    
    return userName;
}

+ (NSArray *)globalLeaderBoardEntries
{
    return @[@"Entry 1", @"Entry 2", @"Entry 3"];
}

+ (NSArray *)friendsLeaderBoardEntries
{
    return nil;
}

+ (void)setPersonalRecordRunningDistance:(int)personalRecordRunningDistance
{
    NSNumber *personalRecord = [NSNumber numberWithInt:personalRecordRunningDistance];
    [MGWU setObject:personalRecord forKey:PERSONAL_RECORD_RUNNING_DISTANCE_KEY];
}

+ (int)personalRecordRunningDistance
{
    int returnValue = 0;
    
    NSDictionary *highscore = [MGWU getMyHighScoreForLeaderboard:DISTANCE_LEADERBOARD];
    
    if (highscore != nil)
    {
        returnValue = [[highscore objectForKey:@"score"] intValue];
    }
    
    Game *game = [[GameMechanics sharedGameMechanics] game];
    
    // check if the current distance is better then the highest one
    if (game.meters > returnValue)
    {
        returnValue = game.meters;
    }
    
    return returnValue;
}

@end
