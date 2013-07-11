//
//  EnemyCache.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/17/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"

/**
 This class stores all enemies. This is necessary, to be able to draw all enemies on one BatchNode.
 Drawing all enemies on one BatchNode is important for performance reasons.
 **/

@interface EnemyCache : CCNode
{
    CCSpriteBatchNode* batch;
    CCSpriteBatchNode* batch2;
    
    // stores all enemies
    NSMutableDictionary* enemies;
    NSMutableDictionary* enemies2;
    BOOL onScreen;

    // count the updates (used to determine when monsters should be spawned)
    int updateCount;
}

@end
