//
//  GameplayScene.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCScene.h"
#import "StoreTableViewCell.h"
#import "PauseScreen.h"
#import "InGameStore.h"
#import "ScoreboardEntryNode.h"
#import "HealthDisplayNode.h"
#import "PopUp.h"
#import "Knight.h"
#import "Spikes.h"
#import "Ramps.h"
#import "NitroButton.h"
#import "Box1.h"


@interface GameplayLayer : CCLayer <StoreDisplayNeedsUpdate, PauseScreenDelegate>
{
    HealthDisplayNode *healthDisplayNode;
    ScoreboardEntryNode *coinsDisplayNode;
    ScoreboardEntryNode *pointsDisplayNode;
    ScoreboardEntryNode *inAppCurrencyDisplayNode;
    // groups health, coins and points display
    CCNode *hudNode;
    
    /* Skip Ahead Button */
    CCMenu *skipAheadMenu;
    CCMenuItemSprite *skipAheadMenuItem;
    
    /* Pause Button */
    CCMenu *pauseButtonMenu;
    CCMenuItemSprite *pauseButtonMenuItem;
    
    /* "GO ON?" popup */
    PopUp *goOnPopUp;
    
    /* "Buy more coins"-Popup */
    InGameStore *inGameStore;
    
    Game *game;
    Knight *knight;
    Spikes* spikes;
    Ramps* ramp;
    /* Jump button */
    NitroButton *nitro;
    /* used to trigger events, that need to run every X update cycles*/
    int updateCount;
    int counter4;
    int counter;
    int num;
    double speedUp;
    int counter2;
    double mult;
    double cap;
    int counter3;
    int counter5;
    int spawnRate;
    BOOL recent;
    BOOL nitroOn;
    BOOL recent2;
    int counter6;
    
    /* stores the exact distance the knight has ran */
    float gainedDistance;
}

// defines if the main menu shall be displayed, or if the game shall start directly. By default the menu is displayed.
@property (nonatomic, assign) BOOL showMainMenu;
@property (nonatomic, assign) BOOL onRamp;
/**
 Tells the game to start
 */
- (void)startGame;

// returns a GamePlayLayer, with an overlayed MainMenu
+ (id)scene;

// return a GamePlayLayer without a MainMenu
+ (id)noMenuScene;

// makes the Heads-Up-Display (healthInfo, pointInfo, etc.) appear. Can be animated.
- (void)showHUD:(BOOL)animated;

// hides the Heads-Up-Display (healthInfo, pointInfo, etc.). Can be animated.
- (void)hideHUD:(BOOL)animated;

@end
