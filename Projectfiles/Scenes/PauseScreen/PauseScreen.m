//
//  PauseScreen.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/10/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "PauseScreen.h"
#import "GameMechanics.h"
#import "STYLES.h"
#import "GameplayLayer.h"
#import "MainMenuLayer.h"
#import "Truth.h"

@interface PauseScreen()

- (void)resumeButtonPressed;

@end

@implementation PauseScreen

- (id)initWithGame:(Game *)game 
{
    self = [super init];
    
    if (self)
    {
        Truth* data = [Truth sharedData];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        self.contentSize = [[CCDirector sharedDirector] winSize];
        // position of screen, animate to screen
        self.position = ccp(self.contentSize.width / 2, self.contentSize.height * 1.5);
        
        // add a background image node
        backgroundNode = [[CCBackgroundColorNode alloc] init];
        backgroundNode.backgroundColor = ccc4(255, 255, 255, 255);
        backgroundNode.contentSize = self.contentSize;
        [self addChild:backgroundNode];
        
        // set anchor points new, since we changed content size
        //self.anchorPoint = ccp(0.5, 0.5);
        backgroundNode.anchorPoint = ccp(0.5, 0.5);
        /*
        // add title label
        CCLabelTTF *storeItemLabel = [CCLabelTTF labelWithString:@"PAUSED"
                                                        fontName:DEFAULT_FONT
                                                        fontSize:32];
        storeItemLabel.color = DEFAULT_FONT_COLOR;
        storeItemLabel.position = ccp(0, 0.5 * self.contentSize.height - 25);
        [self addChild:storeItemLabel];
        */
        // add a resume button
        CCSprite *resumeButtonNormal = [CCSprite spriteWithFile:@"button_playbutton.png"];
        resumeMenuItem = [[CCMenuItemSprite alloc] initWithNormalSprite:resumeButtonNormal selectedSprite:nil disabledSprite:nil target:self selector:@selector(resumeButtonPressed)];
        
        menu = [CCMenu menuWithItems:resumeMenuItem, nil];
        [menu alignItemsHorizontally];
        menu.position = ccp(0, - (0.5 * self.contentSize.height) + resumeButtonNormal.contentSize.height * 0.75);
        [self addChild:menu];
        /*
        // add a missions node
        missionNode = [[MissionsNode alloc] initWithMissions:game.missions];
        missionNode.contentSize = CGSizeMake(240.f, 120.f);
        missionNode.anchorPoint = ccp(0.5, 0.5);
        missionNode.position = ccp(0, 0);
        
        // we want to use the 9Patch background on the pause screen
        missionNode.usesScaleSpriteBackground = TRUE;
         */
        CCMenuItemSprite *replay = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"restart.png"] selectedSprite:[CCSprite spriteWithFile:@"restart.png"]block:^(id sender) {
            GameplayLayer *gameplayLayer2 = [[GameplayLayer alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameplayLayer2];
        }];
        
        replay.scale = .5;
        CCMenu *replayButtonMenu = [CCMenu menuWithItems:replay, nil];
        replayButtonMenu.anchorPoint = ccp(1,0);
        replayButtonMenu.position = ccp(-screenHeight/4, -screenWidth/3);
        [self addChild:replayButtonMenu];
        CCMenuItemSprite *nextButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"next.png"] selectedSprite:[CCSprite spriteWithFile:@"next_pressed.png"]block:^(id sender) {
            MainMenuLayer *gameplayLayer = [[MainMenuLayer alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameplayLayer];
        }];
        
        CCMenu *nextButtonMenu = [CCMenu menuWithItems:nextButton, nil];
        nextButtonMenu.anchorPoint = ccp(1,0);
        nextButtonMenu.position = ccp(screenHeight/4, -screenWidth/3);
        [self addChild:nextButtonMenu];
        
        //[self addChild:missionNode];
        NSString* traveled = [NSString stringWithFormat:@"Current Distance:%i", data.gainedDistance];
        CCLabelTTF* distance = [CCLabelTTF labelWithString:traveled fontName:@"HelveticaNeue-Light" fontSize:20];
        NSString* money = [NSString stringWithFormat:@"Current Coins:%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"coins"]];
        CCLabelTTF* coins = [CCLabelTTF labelWithString:money fontName:@"HelveticaNeue-Light"fontSize:20];
        CCLabelTTF* paused = [CCLabelTTF labelWithString:@"Paused" fontName:@"HelveticaNeue-Light"fontSize:40];
        [self addChild:coins];
        [self addChild:distance];
        [self addChild:paused];
        paused.position = ccp(0, screenWidth/2.8);
        distance.position = ccp(0, screenWidth/12);
        coins.position = ccp(0, -screenWidth/9);
        distance.color = ccc3(0,0,0);
        paused.color = ccc3(0,0,0);
        coins.color = ccc3(0,0,0);
        distance.visible = YES;
        coins.visible = YES;
    }
    [self scheduleUpdate];
    return self;
}

- (void)resumeButtonPressed
{
    [self hideAndResume];
    [self.delegate resumeButtonPressed:self];
}

- (void)present
{
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.2f position:ccp(self.contentSize.width / 2, self.contentSize.height * 0.5)];
    [self runAction:move];
    [missionNode updateCheckmarks];
}

- (void)hideAndResume
{
    if (self.parent != nil)
    {
        // animate off screen
        CGPoint targetPosition = ccp(self.contentSize.width / 2, self.contentSize.height * 1.5);
        CCMoveTo *move = [CCMoveTo actionWithDuration:0.2f position:targetPosition];
        
        CCCallBlock *removeFromParent = [[CCCallBlock alloc] initWithBlock:^{
            [self removeFromParentAndCleanup:TRUE];
            // resume the game
            [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
        }];
        
        CCSequence *hideSequence = [CCSequence actions:move, removeFromParent, nil];
        [self runAction:hideSequence];
    }
}

@end
