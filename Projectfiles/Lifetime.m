//
//  Lifetime.m
//  Wheelchair
//
//  Created by Ben on 15/08/2013.
//  Copyright (c) 2013 MakeGamesWithUs Inc. All rights reserved.
//

#import "Lifetime.h"
#import "Truth.h"
#import "MainmenuLayer.h"

@implementation Lifetime
-(id)init
{
    if (self = [super init])
    {
    CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
    
    [self addChild:background];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    background.position = ccp(screenHeight*2/3, screenWidth/2);
    Truth *data = [Truth sharedData];
    CCLabelTTF *title = [CCLabelTTF labelWithString:@"Lifetime Records" fontName:@"Helvetica-Bold" fontSize:36];
    title.position = ccp(screenHeight/2-30, screenWidth*5/6);
    title.color = ccc3(0,0,0);
    [self addChild:title];
    NSArray *highScoreType = [NSArray arrayWithObjects: @"Max speed:", @"Total meters traveled:",@"Total swipes:", @"Max swipes per second:",@"Seconds spent on ramps:", @"Ramps climbed:",@"Barrells busted:", nil];
    int yPosition = self.contentSize.height - (title.contentSize.height)-50;
    
    for (NSString *highScoreTypes in highScoreType)
    {
        CCLabelTTF *highScoreType = [CCLabelTTF labelWithString:highScoreTypes
                                                        fontName:@"Helvetica"
                                                        fontSize:16];
        highScoreType.color = ccc3(0,0,0);
        highScoreType.anchorPoint = ccp(0, 1);
        highScoreType.position = ccp(screenHeight/4, yPosition);
        [self addChild:highScoreType];
        yPosition -= (5 + highScoreType.contentSize.height);
    }
        
        NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
        
        int hs = [currentHighScore intValue];
        NSString *currentHighScorea = [NSString stringWithFormat:@"%i meters per second", hs];
        NSNumber *currentHighScore2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"distance"];
        int hs2 = [currentHighScore2 intValue];
        NSString *currentHighScore2a = [NSString stringWithFormat:@"%i meters", hs2];
        NSNumber *currentHighScore3 = [[NSUserDefaults standardUserDefaults] objectForKey:@"swipes"];
        int hs3 = [currentHighScore3 intValue];
        NSString* currentHighScore3a = [NSString stringWithFormat:@"%i swipes", hs3];
        NSNumber *currentHighScore4 = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxSwipes"];
        int hs4 = [currentHighScore4 intValue];
        NSString* currentHighScore4a = [NSString stringWithFormat:@"%i swipes per second", hs4];
        NSNumber *currentHighScore5 = [[NSUserDefaults standardUserDefaults] objectForKey:@"timeRamps"];
        double hs5 = [currentHighScore5 doubleValue];
        NSString* currentHighScore5a = [NSString stringWithFormat:@"%f seconds", hs5];
        NSNumber *currentHighScore6 = [[NSUserDefaults standardUserDefaults] objectForKey:@"ramps"];
        int hs6 = [currentHighScore6 intValue];
        NSString* currentHighScore6a = [NSString stringWithFormat:@"%i ramps", hs6];
        NSNumber *currentHighScore7 = [[NSUserDefaults standardUserDefaults] objectForKey:@"ramps"];
        int hs7 = [currentHighScore7 intValue];
        NSString* currentHighScore7a = [NSString stringWithFormat:@"%i barrells", hs7];
     NSArray *highScore = [NSArray arrayWithObjects: currentHighScorea, currentHighScore2a, currentHighScore3a, currentHighScore4a, currentHighScore5a, currentHighScore6a, currentHighScore7a,  nil];
        yPosition = self.contentSize.height - (title.contentSize.height)-50;
       for (NSString *highScoreTypes in highScore)
             {
                 CCLabelTTF *highScoreType = [CCLabelTTF labelWithString:highScoreTypes
                                                                fontName:@"Helvetica"
                                                                fontSize:16];
                 highScoreType.color = ccc3(0,0,0);
                 highScoreType.anchorPoint = ccp(0, 1);
                 highScoreType.position = ccp(screenHeight*2/3, yPosition);
                 [self addChild:highScoreType];
                 yPosition -= (5 + highScoreType.contentSize.height);
             }
        
        CCMenuItemSprite *exit = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"next.png"] selectedSprite:[CCSprite spriteWithFile:@"next_pressed.png"]block:^(id sender) {
            MainMenuLayer *scene = [[MainMenuLayer alloc] init];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        CCMenu *exitMenu = [CCMenu menuWithItems:exit, nil];
        exitMenu.position = ccp(screenHeight/10, screenWidth/2);
        exitMenu.scale = .8
        [self addChild:exitMenu];
        
        
        
    
    [self scheduleUpdate];
        
        
    }
    return self;
    
}
-(void) exitButtonPressed
{
    
}

@end
