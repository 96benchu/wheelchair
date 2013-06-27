//
//  ScoreboardEntryNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"

/**
 Displays an icon and a score.
 **/

@interface ScoreboardEntryNode : CCNode
{
    CCLabelBMFont *scoreLabel;
}

- (id)initWithScoreImage:(NSString *)scoreImage fontFile:(NSString *)fontFile;

@property (nonatomic, assign) int score;
@property (nonatomic, strong) NSString *scoreStringFormat;

@end
