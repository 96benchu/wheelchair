//
//  PersonalBestNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/21/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "PersonalBestNode.h"
#import "STYLES.h"

@implementation PersonalBestNode

- (id)initWithPersonalBest:(int)personalBestArg
{
    self = [super init];
    
    if (self)
    {
        personalBest = personalBestArg;
    }
    
    return self;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
    colorLayer.size = self.contentSize;
    colorLayer.anchorPoint = ccp(0,0);
    [self addChild:colorLayer z:-10];
    
    NSString *personalBestString = [NSString stringWithFormat:@"YOUR BEST: %dm",personalBest];
    
    CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:personalBestString
                                                    fontName:DEFAULT_FONT
                                                    fontSize:18];
    highScoreLabel.color = INVERSE_FONT_COLOR;
    highScoreLabel.anchorPoint = ccp(0, 1);
    highScoreLabel.position = ccp(4, self.contentSize.height-4);
    [self addChild:highScoreLabel];
}

@end
