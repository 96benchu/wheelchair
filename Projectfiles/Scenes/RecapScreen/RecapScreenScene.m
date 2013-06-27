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
#import "Leaderboard.h"

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
        NSString *highscore = [NSString stringWithFormat:@"%d points", game.score];
        NSString *distance = [NSString stringWithFormat:@"%d meters", game.meters];
        NSString *enemiesKilled = [NSString stringWithFormat:@"%d enemies killed", game.enemiesKilled];
        
        NSArray *highScoreStrings = [NSArray arrayWithObjects:highscore, distance, enemiesKilled, nil];

        // setup the statistics panel with the current game information of the user
        statisticsNode = [[StatisticsNode alloc] initWithTitle:@"GAME OVER" highScoreStrings:highScoreStrings];
        statisticsNode.contentSize = CGSizeMake(200, 200);
        statisticsNode.anchorPoint = ccp(0, 1);
        statisticsNode.position = ccp(20 ,screenSize.height - 70);
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
        NSArray *tabTitles = @[@"Missions", @"Leaderboards"];
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
        
        
        /*********** Personal Best *********/
        
        PersonalBestNode *personalBestNode = [[PersonalBestNode alloc] initWithPersonalBest:
                                              [Leaderboard personalRecordRunningDistance]];
        personalBestNode.contentSize = CGSizeMake(200, 30);
        personalBestNode.position = ccp(20, 10);
        [self addChild:personalBestNode];
        
        /*********** Next Button ***********/
        CCMenuItemSprite *nextButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"next.png"] selectedSprite:[CCSprite spriteWithFile:@"next_pressed.png"]block:^(id sender) {
            StoreScreenScene *storeScreenScene = [[StoreScreenScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:storeScreenScene];
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
        [MGWU submitHighScore:game.score byPlayer:username forLeaderboard:HIGHSCORE_LEADERBOARD];
        [MGWU submitHighScore:game.meters byPlayer:username forLeaderboard:DISTANCE_LEADERBOARD];
    } else
    {
        // if no unsername is set yet, prompt dialog and submit highscore then
        [self presentUsernameDialog];
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
