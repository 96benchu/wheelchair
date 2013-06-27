//
//  GhostMonster.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "BasicMonster.h"

/**
 Class for ghost enemy.
 */

@interface BasicMonster : CCSprite

@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) NSInteger hitPoints;
// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;

@property (nonatomic, strong) NSMutableArray *animationFrames;
@property (nonatomic, strong) CCAction *run;
@property (nonatomic, assign) NSInteger initialHitPoints;

- (id)initWithMonsterPicture;
- (void)spawn;
- (void)gotHit;

@end
