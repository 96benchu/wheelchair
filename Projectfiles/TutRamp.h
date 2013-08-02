//
//  TutRamp.h
//  Wheelchair
//
//  Created by Ben on 29/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCLayer.h"

@interface TutRamp : CCSprite
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) BOOL col;
-(id)initWithRampImage;
-(void)detectCol:(CGPoint)pos;
-(void)spawn;

@end
