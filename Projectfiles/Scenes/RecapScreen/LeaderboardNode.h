//
//  LeaderboardNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"
#import "SWTableView.h"
#import "CCBackgroundColorNode.h"
#import "TabNode.h"
#import "CCSpriteBackgroundNode.h"

@interface LeaderboardNode : CCSpriteBackgroundNode <TabNodeProtocol>
{
    NSDictionary *scoreboard;
    NSArray *globalScoreboard;
    NSArray *friendsScoreboard;
    NSDictionary *personalEntry;
    // stores the current yOffset, to layout labels in the leaderboard underneath each other
    int layoutingYPosition;
    
    CCSprite *friendsLeaderBoardNode;
    CCSprite *globalLeaderBoardNode;
}

- (id)initWithScoreBoard:(NSDictionary *)scoreboard;

// updates the content of the scoreboard with the new scores
- (void)reloadWithScoreBoard:(NSDictionary *)scoreboard;

@end
