//
//  Knight.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCSprite.h"

/**
 Class for the hero entity.
 */

@interface Knight : CCSprite
{
    NSMutableArray *animationFramesRun;
    CCAction *run;
    
    NSMutableArray *animationFramesStab;
    CCSequence *stab;
    int a;
    
    BOOL stabDidRun;
}

// defines a hit zone, which is smaller as the sprite, only if this hit zone is hit the knight is injured
@property (nonatomic, assign) CGRect hitZone;

// velocity in pixels per second
@property (nonatomic, assign) CGPoint velocity;

// hit points the knight has
@property (nonatomic, assign) int hitPoints;

// indicates if the knight is currently stabbing
@property (nonatomic, assign) BOOL stabbing;

// indicates if the knight is invincible at the moment
@property (nonatomic, assign) BOOL invincible;

@property(nonatomic, assign) int jumpCounter;

@property(nonatomic, assign) int fuel;

- (id)initWithKnightPicture;
- (void)gotHit;
- (void)jump;
- (void)stab;
-(void)move;
-(void)slowDown:(int)num;
-(void)speedUp:(int)num;

@end
