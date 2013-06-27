//
//  CCNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <UIKit/UIKit.h>

@interface StatisticsNode:CCNode
{
    CCNode<CCLabelProtocol> *titleLabel;
    NSString *title;
    NSArray *highScoreStrings;
}

-(id)initWithTitle:(NSString *)title highScoreStrings:(NSArray *)highScoreStrings;

@end
