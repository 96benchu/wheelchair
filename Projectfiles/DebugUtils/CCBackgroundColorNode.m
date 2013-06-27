//
//  CCNode+CCNode_BackgroundColor.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/22/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCBackgroundColorNode.h"

@implementation CCBackgroundColorNode

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // initialize with random background color
        self.backgroundColor = ccc4(arc4random() % 255,
                                                arc4random() % 255,
                                                arc4random() % 255,
                                                255);
        self.backgroundColorZLayer = -1;
    }
    
    return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:self.backgroundColor];
    colorLayer.size = self.contentSize;
    colorLayer.anchorPoint = ccp(0,0);
    [self addChild:colorLayer z:self.backgroundColorZLayer];
}

@end
