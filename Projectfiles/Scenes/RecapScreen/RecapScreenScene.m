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
#import "Lifetime.h"

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
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
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
        NSNumber *currentHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
        int hs = [currentHighScore intValue];
        NSNumber *currentHighScore2 = [[NSUserDefaults standardUserDefaults] objectForKey:@"distance"];
        int hs2 = [currentHighScore2 intValue];
        NSNumber *currentHighScore3 = [[NSUserDefaults standardUserDefaults] objectForKey:@"swipes"];
        int hs3 = [currentHighScore3 intValue];
        NSNumber *currentHighScore4 = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxSwipes"];
        int hs4 = [currentHighScore4 intValue];
        NSNumber *currentHighScore5 = [[NSUserDefaults standardUserDefaults] objectForKey:@"timeRamps"];
        int hs5 = [currentHighScore5 intValue];
        NSNumber *currentHighScore6 = [[NSUserDefaults standardUserDefaults] objectForKey:@"ramps"];
        int hs6 = [currentHighScore6 intValue];
        NSNumber *currentHighScore7 = [[NSUserDefaults standardUserDefaults] objectForKey:@"barrells"];
        int hs7 = [currentHighScore7 intValue];
        NSNumber *currentHighScore8 = [[NSUserDefaults standardUserDefaults] objectForKey:@"coins"];
        int hs8 = [currentHighScore8 intValue];

        /********** Statistics Panel *********/
        if(data.maxSpeed>=hs)
        {
            hs = data.maxSpeed;
            
        }
        NSNumber *highscore = [NSNumber numberWithInteger:hs];
        NSNumber *distance = [NSNumber numberWithInteger :data.gainedDistance+hs2];
        NSNumber *swipes = [NSNumber numberWithInteger : data.totalSwipes+hs3];
        if(data.maxSwipes>=hs4)
        {	
            hs4= data.maxSwipes;
            
        }
        NSNumber *swipes2 = [NSNumber numberWithInteger :hs4];
        NSNumber *spentRamp = [NSNumber numberWithFloat:data.timeSpent/60 + hs5];
        NSNumber*spentRamp2 = [NSNumber numberWithInteger: data.climbed + hs6];
        NSNumber *barrells = [NSNumber numberWithInteger:data.blasted +hs7];
       // NSNumber *fuel = [NSString stringWithFormat:@"fuel left %i%% ", data.fuelLeft];
       

        
        [[NSUserDefaults standardUserDefaults] setObject:highscore forKey:@"fastest"];
        [[NSUserDefaults standardUserDefaults] setObject:distance forKey:@"distance"];
        [[NSUserDefaults standardUserDefaults] setObject:swipes forKey:@"swipes"];
        [[NSUserDefaults standardUserDefaults] setObject:swipes2 forKey:@"maxSwipes"];
        [[NSUserDefaults standardUserDefaults] setObject:spentRamp forKey:@"timeRamps"];
        [[NSUserDefaults standardUserDefaults] setObject:spentRamp2 forKey:@"ramps"];
        [[NSUserDefaults standardUserDefaults] setObject:barrells forKey:@"barrells"];
        //[[NSUserDefaults standardUserDefaults] setObject:hs8+bonus+coin forKey:@"coins"];
        //[[NSUserDefaults standardUserDefaults] setObject:fuel forKey:@"highS"];
        int coin = ((data.gainedDistance - 500)*(data.gainedDistance - 500))/100;
        if(data.gainedDistance<500)
        {
            coin = 0;
        }
        int bonus = data.fuelLeft/10;
        NSString *distanced = [NSString stringWithFormat:@"%i",data.gainedDistance];
       // NSString *coins1 = [NSString stringWithFormat:@"and earned %i Coins ", coin];
        //NSString *coins2 = [NSString stringWithFormat:@"plus %i bonus fuel coins" , bonus];
         NSString *coins3 = [NSString stringWithFormat:@"%i", bonus+coin];
        NSNumber *coins = [NSNumber numberWithInteger:bonus+coin +hs8];
        [[NSUserDefaults standardUserDefaults] setObject:coins forKey:@"coins"];
        CCLabelTTF *label1 = [CCLabelTTF labelWithString: @"You rolled" fontName:@"HelveticaNeue" fontSize:14];
        CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"meters" fontName:@"HelveticaNeue" fontSize:14];
        CCLabelTTF *label3 = [CCLabelTTF labelWithString:@"and gained" fontName:@"HelveticaNeue" fontSize:14];
        CCLabelTTF *label4 = [CCLabelTTF labelWithString:@"coins"fontName:@"HelveticaNeue" fontSize:14];
        CCLabelTTF *label12 = [CCLabelTTF labelWithString: distanced fontName:@"HelveticaNeue" fontSize:40];
        CCLabelTTF *label32 = [CCLabelTTF labelWithString: coins3 fontName:@"HelveticaNeue" fontSize:40];
        NSString *total = [NSString stringWithFormat:@"%@ coins", coins];
        CCLabelTTF *label5 = [CCLabelTTF labelWithString:total fontName:@"HelveticaNeue" fontSize:18];
        label1.position = ccp(screenHeight/20, screenWidth*2.8/4);
        label12.position = ccp(label1.position.x+label1.contentSize.width+3, screenWidth*2.8/4-7);
        label2.position = ccp(label12.position.x+label12.contentSize.width+2, screenWidth*2.8/4);
        label3.position = ccp(screenHeight/20, screenWidth/1.7);
        label32.position = ccp(label3.position.x+label3.contentSize.width, screenWidth/1.7-7);
        label4.position = ccp(label32.position.x+label32.contentSize.width+2, screenWidth/1.7);
        label1.anchorPoint = ccp(0,0);
        label12.anchorPoint = ccp(0,0);
        label2.anchorPoint = ccp(0,0);
        label32.anchorPoint = ccp(0,0);
        label3.anchorPoint = ccp(0,0);
        label4.anchorPoint = ccp(0,0);
        label1.visible = YES;
        label12.visible = YES;
        label2.visible = YES;
        label3.visible = YES;
        label4.visible = YES;
        label32.visible = YES;
        label1.color = ccc3(0,0,0);
        label2.color = ccc3(0,0,0);
        label3.color = ccc3(0,0,0);
        label4.color = ccc3(0,0,0);
        label12.color = ccc3(0,0,0);
        label32.color = ccc3(0,0,0);
        //NSString *closeCalls = [NSString stringWithFormat:@"%i% close calls with spikes", data.closeCall];
        //NSArray *highScoreStrings = [NSArray arrayWithObjects:distanced,/*highscore, swipes, swipes2, barrells, spentRamp, spentRamp2, fuel,*/ coins1, coins2, coins3, nil];

        // setup the statistics panel with the current game information of the user
        //statisticsNode = [[StatisticsNode alloc] initWithTitle:@"GAME OVER" highScoreStrings:highScoreStrings];
        //statisticsNode.contentSize = CGSizeMake(200, 200);
        //statisticsNode.anchorPoint = ccp(0, 1);
        //statisticsNode.position = ccp(2 ,screenSize.height - 60);
        //[self addChild:statisticsNode];
        
        /********** Mission Panel *********/
        //missionNode = [[MissionsNode alloc] initWithMissions:game.missions];
        //missionNode.contentSize = CGSizeMake(240.f, 201.f);
        // we want to use a fixed size image on the recap screen
        //missionNode.usesScaleSpriteBackground = FALSE;
        
        /********** Leaderboard Panel *********/
        leaderboardNode = [[LeaderboardNode alloc] initWithScoreBoard:nil];
        leaderboardNode.contentSize = CGSizeMake(50.f, 50.f);
        leaderboardNode.position = ccp(screenHeight/5, screenWidth/5);
        //leaderboardNode.anchorPoint = ccp(0,0);
        /********** TabView Panel *********/
        NSArray *tabs = @[leaderboardNode];
        NSArray *tabTitles = @[ @"Leaderboards"];
        tabNode = [[TabNode alloc] initWithTabs:tabs tabTitles:tabTitles];
        tabNode.contentSize = CGSizeMake(100, 100);
        tabNode.anchorPoint = ccp(0,1);
        // initially this view will be off screen and will be animated on screen
        tabNode.position =  ccp(screenSize.width - 20,screenSize.height - 150);
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
        CCLabelTTF *protip = [CCLabelTTF labelWithString:@"Protip: Nitroing while jumping allows" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip1 = [CCLabelTTF labelWithString:@"you to leap over large distances!" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip2 = [CCLabelTTF labelWithString:@"Protip: Long swipes are equivalent to smaller ones!" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip3 = [CCLabelTTF labelWithString:@"Protip: Try swiping in the middle-bottom of your screen;" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip31 = [CCLabelTTF labelWithString:@"your thumb will often block your view otherwise" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip4 = [CCLabelTTF labelWithString:@"Protip: Buy upgrades to go farther and longer!" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip5 = [CCLabelTTF labelWithString:@"Protip: The initial burst of nitro" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip52 = [CCLabelTTF labelWithString:@"is stronger than subsequent usage," fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip51 = [CCLabelTTF labelWithString:@"this effect refreshes every 3 seconds" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip6 = [CCLabelTTF labelWithString:@"Protip: Becareful when using nitro;" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip61 = [CCLabelTTF labelWithString:@"you may find yourself running out" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip62 = [CCLabelTTF labelWithString:@"or accidentally crashing into objects" fontName:@"HelveticaNeue-Light" fontSize:12];
        CCLabelTTF *protip7 = [CCLabelTTF labelWithString:@"Protip: Stop getting hit by stuff!" fontName:@"HelveticaNeue-Light" fontSize:12];
        
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
        protip.position = ccp(screenHeight/23, screenWidth/4.5);
        protip1.position = ccp(screenHeight/23, screenWidth/5.5);
        protip2.position = ccp(screenHeight/23, screenWidth/4.5);
        protip3.position = ccp(screenHeight/23, screenWidth/4.5);
        protip31.position = ccp(screenHeight/23, screenWidth/5.5);
        protip4.position = ccp(screenHeight/23, screenWidth/4.5);
        protip5.position = ccp(screenHeight/23, screenWidth/4.5);
        protip6.position = ccp(screenHeight/23, screenWidth/4.5);
        protip52.position = ccp(screenHeight/23, screenWidth/5.5);
        protip51.position = ccp(screenHeight/23, screenWidth/6.8);
        protip61.position = ccp(screenHeight/23, screenWidth/5.5);
        protip62.position = ccp(screenHeight/23, screenWidth/6.8);
        protip7.position = ccp(screenHeight/23, screenWidth/4.5);
        
        [self addChild:label1];
        [self addChild:label2];
        [self addChild:label3];
        [self addChild:label4];
        [self addChild:label12];
        [self addChild:label32];
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
        CCMenuItemSprite *replay = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"restart.png"] selectedSprite:[CCSprite spriteWithFile:@"restart.png"]block:^(id sender) {
            GameplayLayer *gameplayLayer2 = [[GameplayLayer alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameplayLayer2];
        }];
        
        replay.scale = .5;
         CCMenu *replayButtonMenu = [CCMenu menuWithItems:replay, nil];
        replayButtonMenu.anchorPoint = ccp(1,0);
        replayButtonMenu.position = ccp(screenHeight/3, screenWidth/2.5);
        [self addChild:replayButtonMenu];
        CCMenuItemSprite *shop = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithFile:@"shop-button.png"] selectedSprite:[CCSprite spriteWithFile:@"shop-button.png"]block:^(id sender) {
            StoreScreenScene *gameplayLayer3 = [[StoreScreenScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameplayLayer3];
        }];
        shop.scale = .6;
        
        CCMenu *shopButtonMenu = [CCMenu menuWithItems:shop, nil];
        shopButtonMenu.anchorPoint = ccp(1,0);
        shopButtonMenu.position = ccp(screenHeight/3-shop.contentSize.width+20, screenWidth/2.5);
        [self addChild:shopButtonMenu];
        label5.position = ccp(screenHeight/3-shop.contentSize.width+20, screenWidth/2.5+30);
        label5.visible = YES;
        label5.color = ccc3(0,0,0);
        [self addChild:label5];
        CCMenuItemFont *recordButton = [CCMenuItemFont itemWithString:@"Lifetime Records" block:^(id sender) {
            Lifetime *scene = [[Lifetime alloc] init];
            [[CCDirector sharedDirector] replaceScene:scene];
        }];
        recordButton.color = ccc3(0,0,0);
        CCMenu *recordButtonMenu = [CCMenu menuWithItems: recordButton, nil];
        recordButtonMenu.anchorPoint = ccp(0,0);
        recordButtonMenu.position = ccp(screenHeight*2/3, screenWidth/7);
        recordButton.scale = .5;
        [self addChild:recordButtonMenu];
        
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
