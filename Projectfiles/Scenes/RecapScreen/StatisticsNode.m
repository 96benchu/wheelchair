//
//  CCNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "StatisticsNode.h"
#import "STYLES.h"

#define STATISTICS_PANEL_MARGIN_LEFT 20

@implementation StatisticsNode

-(id)initWithTitle:(NSString *)t highScoreStrings:(NSArray *)h
{
    self = [super init];
    
    if (self)
    {
        title = t;
        highScoreStrings = h;
    }
    
    return self;
}

#pragma mark - Node Lifecyle

- (void)onExit
{
    [super onExit];
    
    [self removeAllChildren];
    titleLabel = nil;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    /* title label */
    CCLabelTTF *titleLabelTemp = [CCLabelTTF labelWithString:title
                                                       fontName:DEFAULT_FONT
                                                       fontSize:28];
    titleLabelTemp.color = DEFAULT_FONT_COLOR;
    titleLabelTemp.anchorPoint = ccp(0.5, 1);
    titleLabelTemp.position = ccp(self.contentSize.width / 2.0f, self.contentSize.height);
    titleLabelTemp.size = CGSizeMake(self.contentSize.width, titleLabelTemp.size.height);
    titleLabel = titleLabelTemp;

    [self addChild:titleLabel];
    
    int yPosition = self.contentSize.height - (titleLabel.contentSize.height);
    
    for (NSString *highScoreString in highScoreStrings) {
        CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:highScoreString
                                                        fontName:DEFAULT_FONT
                                                        fontSize:20];
        highScoreLabel.color = DEFAULT_FONT_COLOR;
        highScoreLabel.anchorPoint = ccp(0, 1);
        highScoreLabel.position = ccp(STATISTICS_PANEL_MARGIN_LEFT, yPosition);
        [self addChild:highScoreLabel];
        yPosition -= (5 + highScoreLabel.contentSize.height);
    }
}
@end
