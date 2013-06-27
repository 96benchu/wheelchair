//
//  MainMenuLayer.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "MainMenuLayer.h"
#import "RecapScreenScene.h"
#import "StoreScreenScene.h"
#import "GameplayLayer.h"
#import "Leaderboard.h"
#import "STYLES.h"
#import "Mission.h"
#import "Store.h"
#import "GameMechanics.h"

#define TITLE_LABEL @"Endless Runner Demo Game"
#define TITLE_AS_SPRITE TRUE

@interface MainMenuLayer ()

@end

@implementation MainMenuLayer


-(id) init
{
	if (self = [super init])
    {
        // setup In-App-Purchase Store
        [Store setupDefault];
        
        // set background color
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:SCREEN_BG_COLOR_TRANSPARENT];
        [self addChild:colorLayer z:0];
    
        //setup the start menu title
        if (!TITLE_AS_SPRITE) {
            // OPTION 1: Title as Text
            CCLabelTTF *tempStartTitleLabel = [CCLabelTTF labelWithString:TITLE_LABEL
                                                   fontName:@"Arial"
                                                   fontSize:20];
            tempStartTitleLabel.color = DEFAULT_FONT_COLOR;
            startTitleLabel = tempStartTitleLabel;
        } else {
            // OPTION 2: Title as Sprite
            CCSprite *startLabelSprite = [CCSprite spriteWithFile:@"title.png"];
            startTitleLabel = startLabelSprite;
        }
        
        CGPoint screenCenter = [CCDirector sharedDirector].screenCenter;
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        
        // place the startTitleLabel off-screen, later we will animate it on screen 
        startTitleLabel.position = ccp (screenCenter.x, screenSize.height + 100);
        
        // this will be the point, we will animate the title to
        startTitleLabelTargetPoint = ccp(screenCenter.x, screenSize.height - 80);

		[self addChild:startTitleLabel];
        
        /* add a start button */
        CCSprite *normalStartButton = [CCSprite spriteWithFile:@"mainmenu.png"];
        CCSprite *selectedStartButton = [CCSprite spriteWithFile:@"mainmenu.png"];
        startButton = [CCMenuItemSprite itemWithNormalSprite:normalStartButton selectedSprite:selectedStartButton target:self selector:@selector(startButtonPressed)];
        storeButton = [CCMenuItemFont itemWithString:@"Store" block:^(id sender) {
            CCScene *scene = [[StoreScreenScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        storeButton.color = DEFAULT_FONT_COLOR;

        startMenu = [CCMenu menuWithItems:startButton, storeButton, nil];
        startMenu.position = ccp(screenCenter.x, screenCenter.y - 50);
        [startMenu alignItemsVertically];
        [self addChild: startMenu];
	}

	return self;
}

- (void)startButtonPressed
{
    /** Build an action sequence, that moves the main menu of the screen **/
    CCMoveTo *moveOffScreen = [CCMoveTo actionWithDuration:1.f position:ccp(self.position.x, self.contentSize.height * 2)];
    
    CCAction *movementCompleted = [CCCallBlock actionWithBlock:^{
        // cleanup
        self.visible = FALSE;
        [self removeFromParent];
    }];
    
    CCSequence *menuHideMovement = [CCSequence actions:moveOffScreen, movementCompleted, nil];
    [self runAction:menuHideMovement];

    /** Start the game and display the HUD */
    [[[GameMechanics sharedGameMechanics] gameScene] startGame];
    [[[GameMechanics sharedGameMechanics] gameScene] showHUD:TRUE];
}

#pragma mark - Scene Lifecyle

/**
 This method is called when the scene becomes visible. You should add any code, that shall be executed once
 the scene is visible, to this method.
 */
-(void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    // animate the title on to screen
    CCMoveTo *move = [CCMoveTo actionWithDuration:1.f position:startTitleLabelTargetPoint];
    id easeMove = [CCEaseBackInOut actionWithAction:move];
    [startTitleLabel runAction: easeMove];
    
    // set game state to "MenuState" when this menu appears
    [[GameMechanics sharedGameMechanics] setGameState:GameStateMenu];
    
    // hide the HUD of the gamePlayLayer
    [[[GameMechanics sharedGameMechanics] gameScene] hideHUD:FALSE];
}

@end
