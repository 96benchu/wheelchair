//
//  ScoreboardEntryNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "ScoreboardEntryNode.h"

@implementation ScoreboardEntryNode

@synthesize score = _score;

- (id)initWithScoreImage:(NSString *)scoreImage fontFile:(NSString *)fontFile
{
    self = [super init];
    
    if (self)
    {
        self.scoreStringFormat = @"%d";
        scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:fontFile];
        scoreLabel.anchorPoint = ccp(0,0.5);
        [self addChild:scoreLabel];
        
        if (scoreImage)
        {
            CCSprite *scoreIcon = [CCSprite spriteWithFile:scoreImage];
            [self addChild:scoreIcon];
            
            // move the score label to the right of the icon
            scoreLabel.position = ccp(scoreLabel.position.x + scoreIcon.contentSize.width, scoreLabel.position.y);
            //scoreIcon.position = ccp(scoreIcon.position.x, scoreIcon.contentSize.height);
        }
    }
    
    return self;
}

- (void)setScore:(int)score
{
    _score = score;
    
    scoreLabel.string = [NSString stringWithFormat:_scoreStringFormat, score];
}

@end
