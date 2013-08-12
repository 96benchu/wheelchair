//
//  Box1.h
//  Wheelchair
//
//  Created by Ben on 09/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCLayer.h"

@interface Box1 : CCSprite

{

}
@property (nonatomic, assign) CGPoint velocity;
-(id)initWithBoxImage;
-(void)spawn;
-(void)gotStolen;
@end
