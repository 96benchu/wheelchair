//
//  Truth.h
//  Wheelchair
//
//  Created by Ben on 02/07/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "CCLayer.h"

@interface Truth : NSObject
{
}
@property (nonatomic) BOOL onRamp;
@property (nonatomic) CGSize sprite;
@property (nonatomic) CGPoint pos;
@property (nonatomic) float scrollSpeed;
@property (nonatomic) BOOL hit;
@property (nonatomic) int gainedDistance;
@property (nonatomic) BOOL recent;
+(Truth*) sharedData;
@end
