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
#import "TutRamp.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface GameplayLayer : CCLayer <StoreDisplayNeedsUpdate, PauseScreenDelegate>
{
    HealthDisplayNode *healthDisplayNode;
    ScoreboardEntryNode *coinsDisplayNode;
    ScoreboardEntryNode *pointsDisplayNode;
    ScoreboardEntryNode *inAppCurrencyDisplayNode;
    ScoreboardEntryNode *spikesDisplayNode;
    ScoreboardEntryNode *spikesDisplayNode2;
    // groups health, coins and points display
    CCNode *hudNode;
    
    /* Skip Ahead Button */
    CCMenu *skipAheadMenu;
    CCMenuItemSprite *skipAheadMenuItem;
    
    /* Pause Button */
    CCSprite* arrow;
    CCSprite* fire;
    CCMenu *pauseButtonMenu;
    CCMenuItemSprite *pauseButtonMenuItem;
    
    /* "GO ON?" popup */
    PopUp *goOnPopUp;
    
    /* "Buy more coins"-Popup */
    InGameStore *inGameStore;
    CCSprite* nitroBar;
    CCSprite* nitroBarFrame;
    Game *game;
    Knight *knight;
    Spikes* spikes;
    TutRamp* ramp;
    CCLabelTTF *label;
    CCLabelTTF *label2;
    CCLabelTTF *label3;
    CCLabelTTF *label4;
    CCLabelTTF *label5;
    CCLabelTTF *label6;
    CCLabelTTF *jumpLabel;
    CCLabelTTF *nitroLabel;
    CCLabelTTF *nitroLabel2;
    /* Jump button */
    CCMenu *jumpButtonMenu;
    CCMenuItemSprite *jumpButtonMenuItem;
    NitroButton *nitro;
    CCSprite* arrowButton;
    CCSprite* arrowButton2;
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
    int counter7;
    int counter8;
    int counter9;
    float capDivider;
    BOOL recent4;
    BOOL text1;
    /* stores the exact distance the knight has ran */
    float gainedDistance;
    BOOL recent3;
    BOOL recent5;
    int gainedDistance2;
    int counter10;
    BOOL text2;
    BOOL text21;
    BOOL recent31;
    BOOL text3;
    BOOL text31;
    BOOL text4;
    BOOL text41;
    int counter11;
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
