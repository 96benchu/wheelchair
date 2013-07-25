//
//  Coins.h
//  Wheelchair
//
//  Created by Ben on 18/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCLayer.h"

@interface Coins : CCSprite
{

}


@property (nonatomic, assign) CGPoint velocity;
-(id)initWithCoinImage;
-(void)spawn:(int)x:(int)y;
@end
