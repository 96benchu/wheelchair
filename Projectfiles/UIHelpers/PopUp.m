//
//  PopUp.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/28/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//
//

#import "PopUp.h"
#import "CCBackgroundColorNode.h"

@implementation PopUp

- (void)presentOnNode:(CCNode *)parentNode
{
    // add to the most front layer
    [parentNode addChild:self z:MAX_INT];
    self.anchorPoint = ccp(0.5, 0.5);
    self.position = ccp(parentNode.contentSize.width / 2, parentNode.contentSize.height / 2);
    
    // add this layer, to swallow touches as long as the popup is presented
    // TODO: add implementation for touch swallowing
    layer = [[CCLayerSwallowsTouches alloc] init];
    layer.contentSize = parentNode.contentSize;
    [parentNode addChild:layer z:MAX_INT-1];
}

- (void)dismiss
{
    [self removeFromParent];
    [layer removeFromParent];
}

@end
