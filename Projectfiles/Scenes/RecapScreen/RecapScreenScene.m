//
//  RecapScreenLayer.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/14/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "RecapScreenScene.h"
#import "STYLES.h"
#import "Mission.h"
#import "RunDistanceMission.h"
#import "StoreScreenScene.h"
#import "StatisticsNode.h"
#import "MissionsNode.h"
#import "TabNode.h"
#import "PersonalBestNode.h"
#import "GameplayLayer.h"
#import "MainMenuLayer.h"
#import "Leaderboard.h"
#import "Truth.h"

@interface RecapScreenScene()

//private Methods go here
- (void)presentUsernameDialog;
// method called after facebook login is completed by player
- (void)facebookLoginCompleted:(NSString *)response;
// submit score to leaderboard
- (void)submitScoreDelayed;

@end

@implementation RecapScreenScene

- (id)init
{
    @throw @"Do not use the init-method of this class. Use initWithGame instead.";
}

- (id)initWithGame:(Game *)g
{
    self = [super init];
    
    if (self)
    {
        game = g;
        Truth *data = [Truth sharedData];
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        
        // set the background color
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:SCREEN_BG_COLOR];
        [self addChild:colorLayer z:0];
        
        /*
         We are building this screen with different modules. One module (StatistsicsPanel) will show
         the information of the game session the player has just completed.
         The second panel (tabNode) is a UI component with multiple tabs.
         One tab will show the completed missions (MissionNode), another one will show the leaderboard (LeaderboardNode)
         */
        
        /********** Statistics Panel *********/
        NSString *highscore = [NSString stringWithFormat:@"Max speed: %i meters per second", data.maxSpeed];
        NSString *distance = [NSString stringWithFormat:@"%i meters traveled", data.gainedDistance/2];
        NSString *swipes = [NSString stringWithFormat:@"%i total swipes" , data.totalSwipes];
        NSString *swipes2 = [NSString stringWithFormat:@"Max swipes per second: %i", data.maxSwipes];
        NSString *spentRamp = [NSString stringWithFormat:@"%i seconds spent on ramps", (int)data.timeSpent/60];
        NSString *spentRamp2 = [NSString stringWithFormat:@"%i ramps climbed", data.climbed];
        NSString *barrells = [NSString stringWithFormat:@"%i barrells busted", data.blasted];
        NSString *fuel = [NSString stringWithFormat:@"fuel left %i%% ", data.fuelLeft];
        int coin = (data.gainedDistance - 500)/25;
        if(coin<0)
        {
            coin = 0;
        }
        int bonus = data.fuelLeft/10;
        NSString *coins = [NSString stringWithFormat:@"Coins earned this round:%i", coin];
        NSString *coins2 = [NSString stringWithFormat:@"+bonus fuel:%i for %i coins" , bonus,bonus+coin];
        //NSString *closeCalls = [NSString stringWithFormat:@"%i% close calls with spikes", data.closeCall];
        NSArray *highScoreStrings = [NSArray arrayWithObjects:distance,/*highscore, swipes, swipes2, barrells, spentRamp, spentRamp2, fuel,*/ coins, coins2, nil];

        // setup the statistics panel with the current game information of the user
        statisticsNode = [[StatisticsNode alloc] initWithTitle:@"GAME OVER" highScoreStrings:highScoreStrings];
        statisticsNode.contentSize = CGSizeMake(200, 200);
        statisticsNode.anchorPoint = ccp(0, 1);
        statisticsNode.position = ccp(2 ,screenSize.height - 60);
        [self addChild:statisticsNode];
        
        /********** Mission Panel *********/
        missionNode = [[MissionsNode alloc] initWithMissions:game.missions];
        missionNode.contentSize = CGSizeMake(240.f, 201.f);
        // we want to use a fixed size image on the recap screen
        missionNode.usesScaleSpriteBackground = FALSE;
        
        /********** Leaderboard Panel *********/
        leaderboardNode = [[LeaderboardNode alloc] initWithScoreBoard:nil];
        leaderboardNode.contentSize = CGSizeMake(240.f, 201.f);
        
        /********** TabView Panel *********/
        NSArray *tabs = @[missionNode, leaderboardNode];
        NSArray *tabTitles = @[@"Achievements", @"Leaderboards"];
        tabNode = [[TabNode alloc] initWithTabs:tabs tabTitles:tabTitles];
        tabNode.contentSize = CGSizeMake(270, 208);
        tabNode.anchorPoint = ccp(0,1);
        // initially this view will be off screen and will be animated on screen
        tabNode.position =  ccp(screenSize.width - 30,screenSize.height - 20);
        [self addChild:tabNode];
        
        /*********** Facebook, Twitter, MGWU and MoreGames Menu **********/
        CCMenuItemSprite *mgwuIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"mmenu.png"] selectedSprite:[CCSprite spriteWithFile:@"mmenu_pressed.png"] target:self selector:@selector(mguwIconPressed)];
        
        CCMenuItemSprite *moreGamesIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"moregames.png"] selectedSprite:[CCSprite spriteWithFile:@"moregames_pressed.png"] target:self selector:@selector(moreGamesIconPressed)];
                                           
        CCMenuItemSprite *facebookIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"facebook.png"] selectedSprite:[CCSprite spriteWithFile:@"facebook_pressed.png"] target:self selector:@selector(fbIconPressed)];
                                          
        CCMenuItemSprite *twitterIcon = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"twitter.png"] selectedSprite:[CCSprite spriteWithFile:@"twitter_pressed.png"] target:self selector:@selector(twitterIconPressed)];
        
        CCMenu *socialMenu = [CCMenu menuWithItems:mgwuIcon, moreGamesIcon, facebookIcon, twitterIcon, nil];
        socialMenu.position = ccp(100, self.contentSize.height-40);
        socialMenu.anchorPoint = ccp(0,1);
        [socialMenu alignItemsHorizontallyWithPadding:0.f];
        [self addChild:socialMenu];
        CCLabelTTF *protip = [CCLabelTTF labelWithString:@"Protip: Nitroing while jumping allows" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip1 = [CCLabelTTF labelWithString:@"you to leap over large distances!" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip2 = [CCLabelTTF labelWithString:@"Protip: Long swipes are equivalent to smaller ones!" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip3 = [CCLabelTTF labelWithString:@"Protip: Try swiping in the middle-bottom of your screen;" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip31 = [CCLabelTTF labelWithString:@"your thumb will often block your view otherwise" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip4 = [CCLabelTTF labelWithString:@"Protip: Buy upgrades to go farther and longer!" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip5 = [CCLabelTTF labelWithString:@"Protip: The initial burst of nitro" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip52 = [CCLabelTTF labelWithString:@" is stronger than subsequent usage," fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip51 = [CCLabelTTF labelWithString:@"this effect refreshes every 3 seconds" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip6 = [CCLabelTTF labelWithString:@"Protip: Becareful when using nitro;" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip61 = [CCLabelTTF labelWithString:@"you may find yourself running out" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip62 = [CCLabelTTF labelWithString:@"or accidentally crashing into objects" fontName:@"Helvetica" fontSize:12];
        CCLabelTTF *protip7 = [CCLabelTTF labelWithString:@"Protip: Stop getting hit by stuff!" fontName:@"Helvetica" fontSize:12];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        int rand = arc4random()%7;
        protip.visible = NO;
        protip1.visible = NO;
        protip2.visible = NO;
        protip3.visible = NO;
        protip31.visible= NO;
        protip4.visible = NO;
        protip5.visible = NO;
        protip52.visible = NO;
        protip51.visible = NO;
        protip6.visible = NO;
        protip61.visible = NO;
        protip62.visible = NO;
        protip7.visible =NO;
        protip.color = ccc3(0,0,0);
        protip1.color = ccc3(0,0,0);
        protip2.color = ccc3(0,0,0);
        protip3.color = ccc3(0,0,0);
        protip31.color = ccc3(0,0,0);
        protip4.color = ccc3(0,0,0);
        protip5.color = ccc3(0,0,0);
        protip52.color = ccc3(0,0,0);
        protip51.color = ccc3(0,0,0);
        protip6.color = ccc3(0,0,0);
        protip61.color = ccc3(0,0,0);
        protip62.color = ccc3(0,0,0);
        protip7.color = ccc3(0,0,0);
        [self addChild:protip];
        [self addChild:protip1];
        [self addChild:protip2];
        [self addChild:protip3];
        [self addChild:protip31];
        [self addChild:protip4];
        [self addChild:protip5];
        [self addChild:protip51];
        [self addChild:protip52];
        [self addChild:protip6];
        [self addChild:protip61];
        [self addChild:protip62];
        [self addChild:protip7];
        protip.anchorPoint = ccp(0,0);
        protip1.anchorPoint = ccp(0,0);
        protip2.anchorPoint = ccp(0,0);
        protip3.anchorPoint = ccp(0,0);
        protip31.anchorPoint = ccp(0,0);
        protip4.anchorPoint = ccp(0,0);
        protip5.anchorPoint = ccp(0,0);
        protip51.anchorPoint = ccp(0,0);
        protip52.anchorPoint = ccp(0,0);
        protip6.anchorPoint = ccp(0,0);
        protip61.anchorPoint = ccp(0,0);
        protip62.anchorPoint = ccp(0,0);
        protip7.anchorPoint = ccp(0,0);
        protip.position = ccp(screenHeight/23, screenWidth/3.5);
        protip1.position = ccp(screenHeight/23, screenWidth/4.2);
        protip2.position = ccp(screenHeight/23, screenWidth/3.5);
        protip3.position = ccp(screenHeight/23, screenWidth/3.5);
        protip31.position = ccp(screenHeight/23, screenWidth/4.2);
        protip4.position = ccp(screenHeight/23, screenWidth/3.5);
        protip5.position = ccp(screenHeight/23, screenWidth/3.5);
        protip6.position = ccp(screenHeight/23, screenWidth/3.5);
        protip52.position = ccp(screenHeight/23, screenWidth/4.2);
        protip51.position = ccp(screenHeight/23, screenWidth/5.2);
        protip61.position = ccp(screenHeight/23, screenWidth/4.2);
        protip62.position = ccp(screenHeight/23, screenWidth/5.2);
        protip7.position = ccp(screenHeight/23, screenWidth/3.5);
        
        
        if(rand ==1)
        {
            protip.visible = YES;
            protip1.visible= YES;
        }
        else if(rand == 2)
        {
            protip2.visible = YES;
        }
        else if(rand == 3)
        {
            protip3.visible = YES;
            protip31.visible = YES;
        }
        else if(rand ==4)
        {
            protip4.visible = YES;
        }
        else if(rand ==5)
        {
            protip5.visible = YES;
            protip52.visible = YES;
            protip51.visible = YES;
        }
        else if(rand ==6)
        {
            protip6.visible = YES;
            protip61.visible = YES;
            protip62.visible = YES;
        }
        else
        {
            protip7.visible = YES;
        }
        /*********** Personal Best *********/
        
        PersonalBestNode *personalBestNode = [[PersonalBestNode alloc] initWithPersonalBest:
                                              [Leaderboard personalRecordRunningDistance]];
        personalBestNode.contentSize = CGSizeMake(200, 30);
        personalBestNode.position = ccp(20, 10);
        [self addChild:personalBestNode];
        
        /*********** Next Button ***********/
        CCMenuItemSprite *nextButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"next.png"] selectedSprite:[CCSprite spriteWithFile:@"next_pressed.png"]block:^(id sender) {
            MainMenuLayer *gameplayLayer = [[MainMenuLayer alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameplayLayer];
        }];
        
        CCMenu *nextButtonMenu = [CCMenu menuWithItems:nextButton, nil];
        nextButtonMenu.anchorPoint = ccp(1,0);
        nextButtonMenu.position = ccp(self.contentSize.width - 60, 40);
        [self addChild:nextButtonMenu];
    }
    
    return self;
}

// This is executed, when the scene is shown for the first time
- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    NSString *username = [Leaderboard userName];
    
    if (username)
    {
        //[MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD];
        //[MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];
    } else
    {
        // if no unsername is set yet, prompt dialog and submit highscore then
        //[self presentUsernameDialog];
    }
    
    // animate the tabNode on to screen
    CGSize screenSize = [CCDirector sharedDirector].screenSize;
    CGPoint targetPoint = ccp(screenSize.width - 240, tabNode.position.y);
    CCMoveTo *move = [CCMoveTo actionWithDuration:1.f position:targetPoint];
    id easeMove = [CCEaseBackInOut actionWithAction:move];
    [tabNode runAction: easeMove];
    

    // refresh missions on missions node
    [self scheduleOnce:@selector(updateMissions) delay:2.f];
}

#pragma mark - Button Callbacks

- (void)mguwIconPressed
{
    [MGWU displayAboutPage];
}

- (void)moreGamesIconPressed
{
    [MGWU displayCrossPromo];
}

- (void)fbIconPressed
{
    // share on facebook
    NSString *shareTitle = [NSString stringWithFormat:@"Checkout this amazing game! I challenge all of you in MGWU Runner Template! Can you beat my score of %d ?", [Leaderboard personalRecordRunningDistance]];
    NSString *caption = @"MGWU Runner Template is an amazingly fun game.";
    [MGWU shareWithTitle:shareTitle caption:caption andDescription:@"MGWU teaches you to build iPhone games! Visit makegameswith.us for further information."];
}

- (void)twitterIconPressed
{
    NSString *tweetMessage = [NSString stringWithFormat:@"Checkout this amazing game: @MGWU_Runner_Template! @MakeGamesWithUs"];
    [MGWU postToTwitter:tweetMessage];
}

- (void)updateMissions
{
    // tell the game to replace all completed missions with new ones
    [game replaceCompletedMission];
    [missionNode refreshWithMission:[game.missions copy]];
}

- (void)presentUsernameDialog
{
    usernamePrompt = [[UIAlertView alloc] init];
    usernamePrompt.alertViewStyle = UIAlertViewStylePlainTextInput;
    usernamePrompt.title = @"Enter username or login with Facebook.";
    [usernamePrompt addButtonWithTitle:@"OK"];
    [usernamePrompt addButtonWithTitle:@"Facebook"];
    [usernamePrompt show];
    usernamePrompt.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == usernamePrompt)
    {
        if (buttonIndex == 0)
        {
            // user name entered
            UITextField *usernameTextField = [alertView textFieldAtIndex:0];
            NSString *username = usernameTextField.text;
            // save the user name
            [Leaderboard setUserName:username];
            [MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD withCallback:@selector(receivedScores:) onTarget:self];
            [MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];

        } else if (buttonIndex == 1)
        {
            // attempt to login via Facebook
            // set a flag, that shows, that we are waiting for a facebook login
            [usernamePrompt dismissWithClickedButtonIndex:1 animated:FALSE];
            waitingForFacebookLogin = TRUE;
            [MGWU loginToFacebookWithCallback:@selector(facebookLoginCompleted:) onTarget:self];
        }
    }
}

- (void)facebookLoginCompleted:(NSString *)response
{
    if ([response isEqualToString:@"Success"])
    {
        // since we are succesfully logged in to facebook, username will now be the facebook name
        [usernamePrompt dismissWithClickedButtonIndex:1 animated:FALSE];
        // needs to be called delayed since MGWU currently only allows one callback-method beeing executed at a time 
        [self performSelector:@selector(submitScoreDelayed) withObject:nil afterDelay:0.01f];
 
    } else
    {
        // present InputView again
        [self presentUsernameDialog];
    }
}

- (void)submitScoreDelayed
{
    NSString *username = [Leaderboard userName];
    [MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD];
    [MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];
}

- (void)receivedScores:(NSDictionary*)scores
{    
    [leaderboardNode reloadWithScoreBoard:scores];
}

- (void)didEnterForeground
{
    if (waitingForFacebookLogin)
    {
        [self presentUsernameDialog];
    }
}

@end
