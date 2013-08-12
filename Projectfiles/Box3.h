//
//  Box3.h
//  Wheelchair
//
//  Created by Ben on 31/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCLayer.h"

@interface Box3 : CCSprite
@property (nonatomic, assign) CGPoint velocity;
-(id)initWithBox3Image;
-(void)spawn;
-(void)gotStolen;
@end
