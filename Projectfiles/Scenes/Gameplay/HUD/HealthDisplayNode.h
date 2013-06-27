//
//  HealthDisplayNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"

/**
 Displays the current health of the games hero.
 **/

@interface HealthDisplayNode : CCNode
{
    NSString *healthImage;
    NSString *lostHealthImage;
    int maxHealth;
    NSMutableArray *healthSprites;
    CCTexture2D *healthTexture;
    CCTexture2D *lostHealthTexture;
}

- (id)initWithHealthImage:(NSString*)healthImage lostHealthImage:(NSString*)lostHealthImage maxHealth:(int)maxHealth;

@property (nonatomic, assign) int health;

@end
