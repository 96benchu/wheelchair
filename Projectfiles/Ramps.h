//
//  Ramps.h
//  Wheelchair
//
//  Created by Ben on 27/06/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//
#import "BasicMonster.h"
@interface Ramps : CCSprite

{
}
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) BOOL col;
-(id)initWithRampImage;
-(void)detectCol:(CGPoint)pos;
-(void)spawn;
@end
