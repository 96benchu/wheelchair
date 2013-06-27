//
//  RecapScreenLayer.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCLayer.h"
#import "Game.h"
#import "MissionsNode.h"
#import "LeaderboardNode.h"

@interface RecapScreenScene : CCScene <UIAlertViewDelegate>
{
    Game *game;
    /* The statisticsNode groups GAME OVER and the results of the last game */
    CCNode *statisticsNode;
    CCNode *tabNode;
    LeaderboardNode *leaderboardNode;
    MissionsNode *missionNode;
    UIAlertView *usernamePrompt;
    BOOL waitingForFacebookLogin;
}

- (id)initWithGame:(Game *)game;
- (void)didEnterForeground;
@end
