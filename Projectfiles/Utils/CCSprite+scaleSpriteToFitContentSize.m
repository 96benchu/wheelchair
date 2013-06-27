//
//  CCSprite+CCSprite_scaleSpriteToFitContentSize.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/23/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCSprite+scaleSpriteToFitContentSize.h"

@implementation CCSprite (scaleSpriteToFitContentSize)

- (void)scaleSpriteToFitContentSize
{
    self.scaleX =  self.contentSize.width / self.texture.contentSize.width;
    self.scaleY =  self.contentSize.height / self.texture.contentSize.height;
}

@end
