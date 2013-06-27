//
//  MissionsNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"
#import "CCNinePatchBackgroundNode.h"
#import "CCSpriteBackgroundNode.h"
#import "TabNode.h"

@class MissionsNode;

@interface MissionsNode : CCNode <TabNodeProtocol>
{
    NSArray *missions;
    
    // stores the missionNodes in exact same order as the missions are stored
    NSMutableArray *missionNodes;
    
    CCNode *backgroundNode;
    int numberOfRows;
}

@property (nonatomic, assign) BOOL usesScaleSpriteBackground;

- (id)initWithMissions:(NSArray *)missions;

// refresh with a new set of missions. Missions that stayed the same, will be displayed regulary. Missions that have been replaced, will be replaced with an animation
- (void)refreshWithMission:(NSArray *)missions;

// checks if missions are completed and adds checkmarks (not animated)
- (void)updateCheckmarks;

@end
