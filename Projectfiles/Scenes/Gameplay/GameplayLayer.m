//
//  GameplayScene.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "GameplayLayer.h"
#import "ParallaxBackground.h"
#import "Game.h"
#import "BasicMonster.h"
#import "SlowMonster.h"
#import "GameMechanics.h"
#import "EnemyCache.h"
#import "MainMenuLayer.h"
#import "Mission.h"
#import "RecapScreenScene.h"
#import "Store.h"
#import "PopupProvider.h"
#import "CCControlButton.h"
#import "StyleManager.h"
#import "NotificationBox.h"
#import "PauseScreen.h"
#import "Spikes.h"
#import "Ramps.h"

// defines how many update cycles run, before the missions get an update about the current game state
#define MISSION_UPDATE_FREQUENCY 10

@interface GameplayLayer()
/*
 Tells the game to display the skipAhead button for N seconds.
 After the N seconds the button will automatically dissapear.
 */
- (void)presentSkipAheadButtonWithDuration:(NSTimeInterval)duration;

/*
 called when skipAheadButton has been touched
 */
- (void)skipAheadButtonPressed;

/*
 called when pause button was pressed
 */
- (void)pauseButtonPressed;

/*
 called when the player has chosen if he wants to continue the game (for paying coins) or not
 */
- (void)goOnPopUpButtonClicked:(CCControlButton *)sender;

@end

@implementation GameplayLayer

+ (id)scene
{
    CCScene *scene = [CCScene node];
    GameplayLayer* layer = [GameplayLayer node];
    
    // By default we want to show the main menu
    layer.showMainMenu = TRUE;
    
    [scene addChild:layer];
    return scene;
}

+ (id)noMenuScene
{
    CCScene *scene = [CCScene node];
    GameplayLayer* layer = [GameplayLayer node];
    
    // By default we want to show the main menu
    layer.showMainMenu = FALSE;
    
    [scene addChild:layer];
    return scene;
}

#pragma mark - Initialization

- (void)dealloc
{
    /*
     When our object is removed, we need to unregister from all notifications.
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // get screen center
        CGPoint screenCenter = [CCDirector sharedDirector].screenCenter;
        
        // preload particle effects
        // To preload the textures, play each effect once off-screen
        CCParticleSystem* system = [CCParticleSystemQuad particleWithFile:@"fx-explosion.plist"];
        system.positionType = kCCPositionTypeFree;
        system.autoRemoveOnFinish = YES;
        system.position = ccp(MAX_INT, MAX_INT);
        // adding it as child lets the particle effect play
        [self addChild:system];
        
        // add the scrolling background
        ParallaxBackground *background = [ParallaxBackground node];
        [self addChild:background z:-2];
        
        hudNode = [CCNode node];
        [self addChild:hudNode];
        
        // add the knight
        knight = [[Knight alloc] initWithKnightPicture];
        [self addChild:knight];
        knight.anchorPoint = ccp(0,0);
        spikes = [[Spikes alloc] initWithSpikeImage];
        [self addChild:spikes];
        spikes.anchorPoint=ccp(0,0);
        ramp = [[Ramps alloc] initWithRampImage];
        [self addChild:ramp];
        ramp.anchorPoint=ccp(0,0);
        
        // add the health display
        healthDisplayNode = [[HealthDisplayNode alloc] initWithHealthImage:@"heart_filled.png" lostHealthImage:@"heart_empty.png" maxHealth:5];
        [hudNode addChild:healthDisplayNode z:MAX_INT-1];
        healthDisplayNode.position = ccp(screenCenter.x, self.contentSize.height - 18);
        
        // add scoreboard entry for coins
        coinsDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:@"coin.png" fontFile:@"avenir.fnt"];
        coinsDisplayNode.scoreStringFormat = @"%d";
        coinsDisplayNode.position = ccp(20, self.contentSize.height - 26);
        [hudNode addChild:coinsDisplayNode z:MAX_INT-1];
        
        // add scoreboard entry for in-app currency
        inAppCurrencyDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:@"coin.png" fontFile:@"avenir.fnt"];
        inAppCurrencyDisplayNode.scoreStringFormat = @"%d";
        inAppCurrencyDisplayNode.position = ccp(self.contentSize.width - 120, self.contentSize.height - 26);
        inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
        [hudNode addChild:inAppCurrencyDisplayNode z:MAX_INT-1];
        
        // add scoreboard entry for points
        pointsDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:nil fontFile:@"avenir24.fnt"];
        pointsDisplayNode.position = ccp(10, self.contentSize.height - 50);
        pointsDisplayNode.scoreStringFormat = @"%d m";
        [hudNode addChild:pointsDisplayNode z:MAX_INT-1];
        
        // set up the skip ahead menu
        CCSprite *skipAhead = [CCSprite spriteWithFile:@"skipahead.png"];
        CCSprite *skipAheadSelected = [CCSprite spriteWithFile:@"skipahead-pressed.png"];
        skipAheadMenuItem = [CCMenuItemSprite itemWithNormalSprite:skipAhead selectedSprite:skipAheadSelected target:self selector:@selector(skipAheadButtonPressed)];
        skipAheadMenu = [CCMenu menuWithItems:skipAheadMenuItem, nil];
        skipAheadMenu.position = ccp(self.contentSize.width - skipAheadMenuItem.contentSize.width -20, self.contentSize.height - 80);
        // initially skipAheadMenu is hidden
        skipAheadMenu.visible = FALSE;
        [hudNode addChild:skipAheadMenu];
        
        // set up pause button
        CCSprite *pauseButton = [CCSprite spriteWithFile:@"pause.png"];
        CCSprite *pauseButtonPressed = [CCSprite spriteWithFile:@"pause-pressed.png"];
        pauseButtonMenuItem = [CCMenuItemSprite itemWithNormalSprite:pauseButton selectedSprite:pauseButtonPressed target:self selector:@selector(pauseButtonPressed)];
        pauseButtonMenu = [CCMenu menuWithItems:pauseButtonMenuItem, nil];
        pauseButtonMenu.position = ccp(self.contentSize.width - pauseButtonMenuItem.contentSize.width - 4, self.contentSize.height - 58);
        [hudNode addChild:pauseButtonMenu];
        
        // add the enemy cache containing all spawned enemies
        [self addChild:[EnemyCache node]];
        
        // setup a new gaming session
        [self resetGame];
        speedUp =3;
        counter = 0;
        counter2 = 29;
        mult = 10;
        cap=400;
        counter3 = 0;
        num = 3;
        counter4=0;
        counter5=10;
        recent = false;
        [self scheduleUpdate];
        
        /**
         A Notification can be used to broadcast an information to all objects of a game, that are interested in it.
         Here we sign up for the 'GamePaused' and 'GameResumed' information, that is broadcasted by the GameMechanics class. Whenever the game pauses or resumes, we get informed and can react accordingly.
         **/
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePaused) name:@"GamePaused" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameResumed) name:@"GameResumed" object:nil];
    }
    
    return self;
}

- (void)gamePaused
{
    [self pauseSchedulerAndActions];
}

- (void)gameResumed
{
    [self resumeSchedulerAndActions];
}

#pragma mark - Reset Game

- (void)startGame
{
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [self enableGamePlayButtons];
    [self presentSkipAheadButtonWithDuration:5.f];

    /*
     inform all missions, that they have started
     */
    for (Mission *m in game.missions)
    {
        [m missionStart:game];
    }
}

- (void)resetGame
{
    [[GameMechanics sharedGameMechanics] resetGame];
    
    game = [[Game alloc] init];
    [[GameMechanics sharedGameMechanics] setGame:game];
    [[GameMechanics sharedGameMechanics] setKnight:knight];
    // add a reference to this gamePlay scene to the gameMechanics, which allows accessing the scene from other classes
    [[GameMechanics sharedGameMechanics] setGameScene:self];

    // set the default background scroll speed
    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:SCROLL_SPEED_DEFAULT];
    
    /* setup initial values */
    
    // setup knight
    knight.position = ccp(200,20);
    knight.zOrder = 10;
    knight.hitPoints = KNIGHT_HIT_POINTS;
    
    // setup HUD
    healthDisplayNode.health = knight.hitPoints;
    coinsDisplayNode.score = game.score;
    pointsDisplayNode.score = game.meters;
    //setup spikes
    
    spikes.position = ccp(20,300);
    spikes.zOrder = 11;
    spikes.rotation = 106;
    
    ramp.position = ccp(480,20);
    
    // set spwan rate for monsters
    //[[GameMechanics sharedGameMechanics] setSpawnRate:25 forMonsterType:[Ramps class]];
    //[[GameMechanics sharedGameMechanics] setSpawnRate:50 forMonsterType:[SlowMonster class]];
    
    // set gravity (used for jumps)
    [[GameMechanics sharedGameMechanics] setWorldGravity:ccp(0.f, -100.f)];
    
    // set the floor height, this will be the minimum y-Position for all entities
    [[GameMechanics sharedGameMechanics] setFloorHeight:20.f];
}

#pragma mark - Update & Input Events

-(void) accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration
{
	// controls how quickly velocity decelerates (lower = quicker to change direction)
	float deceleration = 0.2f;
	// determines how sensitive the accelerometer reacts (higher = more sensitive)
	float sensitivity = 300.0f;
	// how fast the velocity can be at most
	float maxVelocity = 500;
    	
	// adjust velocity based on current accelerometer acceleration
	float velocityX = knight.velocity.x * deceleration + acceleration.y * sensitivity;
	
	// we must limit the maximum velocity of the player sprite, in both directions
	if (knight.velocity.x > maxVelocity)
	{
		velocityX = maxVelocity;
	}
	else if (knight.velocity.x < - maxVelocity)
	{
		velocityX = - maxVelocity;
	}
    
    knight.velocity = ccp(velocityX, knight.velocity.y);

}

- (void)pushGameStateToMissions
{
    for (Mission *mission in game.missions)
    {
        if (mission.successfullyCompleted)
        {
            // we skip this mission, since it succesfully completed
            continue;
        }
        
        if ([mission respondsToSelector:@selector(generalGameUpdate:)])
        {
            // inform about current game state
            [mission generalGameUpdate:game];
            
            // check if mission is now completed
            if (mission.successfullyCompleted)
            {
                NSString *missionAccomplished = [NSString stringWithFormat:@"Completed: %@", mission.missionDescription];
                [NotificationBox presentNotificationBoxOnNode:self withText:missionAccomplished duration:1.f];
            }
        }
    }
}

- (void) update:(ccTime)delta
{
    // update the amount of in-App currency in pause mode, too
    inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
    
    if ([[GameMechanics sharedGameMechanics] gameState] == GameStateRunning)
    {
        [self updateRunning:delta];
        
        // check if we need to inform missions about current game state
        updateCount++;
        if ((updateCount % MISSION_UPDATE_FREQUENCY) == 0)
        {
            [self pushGameStateToMissions];
        }
    }
}

- (void)updateRunning:(ccTime)delta
{
    // distance depends on the current scrolling speed
    gainedDistance += (delta * [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]) / 5;
    game.meters = (int) (gainedDistance);
    // update the score display
    pointsDisplayNode.score = game.meters;
    coinsDisplayNode.score = game.score;
    healthDisplayNode.health = knight.hitPoints;
    
    KKInput* input = [KKInput sharedInput];
    /*
    if ([input gestureSwipeRecognizedThisFrame])
    {
        KKSwipeGestureDirection dir = input.gestureSwipeDirection;
        switch(dir)
        {
            case KKSwipeGestureDirectionRight:
                counter++;
        }
    }
    counter2++;
    counter4++;
    if(counter2 == 3)
    {
        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
        {
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-num*5];
        }
    }
    if(counter4 == 10)
    {
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+counter*20];
        if(counter*50 < num)
        {
            [knight slowDown:4];
        }
        else if((counter*50 > num) && (knight.position.x<200))
        {
            [knight speedUp:4];
        }
        counter2 = 0;
        counter = 0;
        counter4=0;
        
        if(knight.position.x>208)
        {
            knight.velocity = CGPointMake(0, knight.velocity.y);
        }
         
        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] < 0)
        {
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:0];
        }
    }
    counter3++;
    if(counter3==300)
    {
        if(num<10)
        {
            num++;
        }
        counter3= 0;
    }
    if(knight.position.x<50)
    {
        knight.velocity = CGPointMake(0, knight.velocity.y);
    }
    */
    
    // the gesture recognizer assumes portrait mode, so we need to use rotated swipe directions
    if ([input gestureSwipeRecognizedThisFrame])
    {
        KKSwipeGestureDirection dir = input.gestureSwipeDirection;
        
        // TODO: this needs to be fixed, kobold 2d autotransforms the touches, depending on the device orientation, which is no good for games not supporting all orientations
        switch (dir)
        {
            //if swipe
            case KKSwipeGestureDirectionRight:
                //if falling behind
                    if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] <= cap)
                    {
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+40];

                    }
                    counter5+=5;
                    NSLog([NSString stringWithFormat:@"%i",counter5]);
                    //failsafe
                    if(knight.velocity.x>0)
                    {
                        knight.velocity = CGPointMake(0, knight.velocity.y);
                    }
                break;
                
            case KKSwipeGestureDirectionLeft:
                [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-40];
            default:
                break;
        }
    }
    
    //else if([input anyTouchEndedThisFrame])
    //{
    //    [knight jump];
    //}
    if (knight.hitPoints == 0)
    {
        // knight died, present screen with option to GO ON for paying some coins
        [self presentGoOnPopUp];
    }
    //Speedup function
    /*
    if(counter2 < 300)
    {
        if(knight.position.x >= 200)
        {
            counter2++;
        }
    }
    else
    {
        if(counter3 > 3)
        {
            counter3--;
        }
        counter2=0;
    }
    //Decrease velocity function
    if(counter < counter3)	
    {
            counter++;
    }
    else
    {
        //ahead
        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
        {
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-speedUp*2];
        }
        //behind
        else if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] <= 0)
        {
            [knight slowDown:13];
        }
        counter = 0;
    }
    //failsafe
    if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] <= 0)
    {
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:0];
    }
    else
    {
        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] >= 0)
        {
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-speedUp];
        }
        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] <= 0)
        {
            if(counter2 ==300)
            {
                counter2 = 0;
                speedUp = speedUp+10;
                
            }
            cap =speedUp*1.5;
            [knight slowDown:5];

        }
        counter = 0;
    }
    */
    //ramps!
    [ramp detectCol:ccp(knight.position.x-20, knight.position.y)];
    counter++;
    if(ramp.col == true)
    {
        double x = 327;
        double y = 100;
        double z = y/x;
        double diffX = knight.position.x - ramp.position.x;
        NSLog([NSString stringWithFormat:@"%f",diffX]);

        //NSLog([NSString stringWithFormat:@"%i",diffX]);
        NSLog(ramp.col ? @"Yes" : @"No");
        knight.position = ccp(knight.position.x, diffX*z+20);
        if(((counter==5) || (counter ==10) || (counter ==15)))
        {
            //decreasbackground speed
            double frac = 350/cap;
            if(counter==15)
            {
                if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
                {
                    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]*frac];
                }
            }
                if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
                {
                    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-cap/30];
                }
            if(spikes.position.x<150)
            {
                spikes.velocity = ccp(spikes.velocity.x + speedUp/6, spikes.velocity.y);
            }
            else
            {
                spikes.velocity = ccp(spikes.velocity.x + speedUp/10, spikes.velocity.y);
            }
            recent = true;
            
        }
    }
    //increase speed after leaving ramp
    if(recent == true)
    {
        if(ramp.col==false)
        {
            knight.velocity = ccp(knight.velocity.x, knight.velocity.x*100/327+knight.velocity.y);
            recent = false;
        }
    }
    //decrease background speed
    NSLog(ramp.col ? @"Yes" : @"No");
    if(counter == 15)
    {
            if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
            {
                    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-cap/25];
            }
        // if there's a ramp
        else
        {
            if(ramp.col == false)
            {
                [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:0];
            }
            else
            {
                [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-cap/15];
            }
        }
        counter = 0;
    }
     
    //spikes moving
    counter2++;
    counter3++;
    //determines if spikes moving and gradual speedUp
    
    if(counter2== 30)
    {
        NSLog([NSString stringWithFormat:@"%i",counter5]);
        //spike speedUp
        if(counter5> speedUp)
           {
               if(spikes.position.x> 0)
               {
                   if(spikes.velocity.x>-50)
                   {
                       if(spikes.position.x > 150)
                       {
                           spikes.velocity = ccp(((speedUp)*2/3-counter5)*2+spikes.velocity.x,spikes.velocity.y);
                       }
                       else
                       {
                           spikes.velocity = ccp((speedUp-counter5)*2+spikes.velocity.x,spikes.velocity.y);
                       }
                   }
               }
               else
               {
                   
               }
           }
        //spike slowdown
        else if(speedUp > counter5)
        {
            if(spikes.velocity.x<50)
            {
                if(spikes.position.x<0)
                {
                    spikes.position = ccp(0,20);
                }
                
                spikes.velocity = ccp((speedUp-counter5)*2+spikes.velocity.x,spikes.velocity.y);
            }
        }
        //if on ramp and very slow, in case of stalling on ramp and no movement
        if(([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]<=30) && (ramp.col == true))
        {
            if(spikes.position.x < 100)
            {
                spikes.velocity = ccp((50-[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX])/15+spikes.velocity.x,spikes.velocity.y);
            }
            else
            {
                spikes.velocity = ccp((50-[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX])/10+spikes.velocity.x,spikes.velocity.y);
            }
        }
        //gradual speedup
        if(speedUp<30)
        {
            speedUp+=.2;
            cap+=4;
        }
        counter2=0;
        counter5=0;
    }
    if(counter3 == 300)
    {
        if(cap<700)
        {
            cap+=5;
        }
    }
    //large speedUp
    if(counter3 == 600)
    {
        if(speedUp<30)
        {
            speedUp+=2;
        }
        if(cap<700)
        {
            cap+=50;
        }
        counter3=0;

    }
    //failsafe
    if(spikes.position.x<0)
    {
        NSLog(@"WHY DONT U WORK");
        spikes.velocity = ccp(0,0);
        spikes.position = ccp(0,300);
    }
    //ram velocity
    ramp.velocity = ccp(-1*[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX], ramp.velocity.y);
     




   
}


#pragma mark - Scene Lifecycle

- (void)onEnterTransitionDidFinish
{
    // setup a gesture listener for jumping and stabbing gestures
    [KKInput sharedInput].gestureSwipeEnabled = TRUE;
    // register for accelerometer input, to controll the knight
    self.accelerometerEnabled = NO;
    
    if (self.showMainMenu)
    {
        // add main menu
        MainMenuLayer *mainMenuLayer = [[MainMenuLayer alloc] init];
        [self addChild:mainMenuLayer z:MAX_INT];
    } else
    {
        // start game directly
        [self showHUD:TRUE];
        [self startGame];
    }
}

- (void)onExit
{
    // very important! deactivate the gestureInput, otherwise touches on scrollviews and tableviews will be cancelled!
    [KKInput sharedInput].gestureSwipeEnabled = FALSE;
    self.accelerometerEnabled = FALSE;
}

#pragma mark - UI

- (void)presentGoOnPopUp
{
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
    CCScale9Sprite *backgroundImage = [StyleManager goOnPopUpBackground];
    goOnPopUp = [PopupProvider presentPopUpWithContentString:nil backgroundImage:backgroundImage target:self selector:@selector(goOnPopUpButtonClicked:) buttonTitles:@[@"OK", @"No"]];
    [self disableGameplayButtons];
}

- (void)showHUD:(BOOL)animated
{
    // TODO: implement animated
    hudNode.visible = TRUE;
}

- (void)hideHUD:(BOOL)animated
{
    // TODO: implement animated
    hudNode.visible = FALSE;
}

- (void)presentSkipAheadButtonWithDuration:(NSTimeInterval)duration
{
    skipAheadMenu.visible = TRUE;
    skipAheadMenu.opacity = 0.f;
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:0.5f];
    [skipAheadMenu runAction:fadeIn];
    
    [self scheduleOnce: @selector(hideSkipAheadButton) delay:duration];
}

- (void)hideSkipAheadButton
{
    CCFiniteTimeAction *fadeOut = [CCFadeOut actionWithDuration:1.5f];
    CCCallBlock *hide = [CCCallBlock actionWithBlock:^{
        // execute this code to hide the 'Skip Ahead'-Button, once it is faded out
        skipAheadMenu.visible = FALSE;
        // enable again, so that interaction is possible as soon as the menu is visible again
        skipAheadMenu.enabled = TRUE;
    }];
    
    CCSequence *fadeOutAndHide = [CCSequence actions:fadeOut, hide, nil];

    [skipAheadMenu runAction:fadeOutAndHide];
}

- (void)disableGameplayButtons
{
    pauseButtonMenu.enabled = FALSE;
    skipAheadMenu.enabled = FALSE;
}
- (void)enableGamePlayButtons
{
    pauseButtonMenu.enabled = TRUE;
    skipAheadMenu.enabled = TRUE;
}

#pragma mark - Delegate Methods

/* 
 This method is called, when purchases on the In-Game-Store occur.
 Then we need to update the coins display on the HUD.
 */
- (void)storeDisplayNeedsUpdate
{
    inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
}

- (void)resumeButtonPressed:(PauseScreen *)pauseScreen
{
    // enable the pause button again, since the pause menu is hidden now
    [self enableGamePlayButtons];
}

#pragma mark - Button Callbacks

- (void)skipAheadButtonPressed
{
    if ([Store hasSufficientFundsForSkipAheadAction])
    {    
        skipAheadMenu.enabled = FALSE;
        CCLOG(@"Skip Ahead!");
        [self startSkipAheadMode];
        
        // hide the skip ahead button, after it was pressed
        // we need to cancel the previously scheduled perform selector...
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideSkipAheadButton) object:nil];
        
        // ... in order to execute it directly
        [self hideSkipAheadButton];
    } else
    {
        // pause the game, to allow the player to buy coins 
        [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
        [self presentMoreCoinsPopUpWithTarget:self selector:@selector(returnedFromMoreCoinsScreenFromSkipAheadAction)];
    }
}

- (void)goOnPopUpButtonClicked:(CCControlButton *)sender
{
    CCLOG(@"Button clicked.");
    if (sender.tag == 0)
    {
        if ([Store hasSufficientFundsForGoOnAction])
        {
            // OK button selected
            [goOnPopUp dismiss];
            [self executeGoOnAction];
            [self enableGamePlayButtons];
        } else
        {
            // game is paused in this state already, we only need to present the more coins screen
            // dismiss the popup; presented again when we return from the 'Buy More Coins'-Screen
            [goOnPopUp dismiss];
            [self presentMoreCoinsPopUpWithTarget:self selector:@selector(returnedFromMoreCoinsScreenFromGoOnAction)];
        }
    } else if (sender.tag == 1)
    {
        // Cancel button selected
        [goOnPopUp dismiss];
        game.score ++;
        
        // IMPORTANT: set game state to 'GameStateMenu', otherwise menu animations will no be played
        [[GameMechanics sharedGameMechanics] setGameState:GameStateMenu];
        
        RecapScreenScene *recap = [[RecapScreenScene alloc] initWithGame:game];
        [[CCDirector sharedDirector] replaceScene:recap];
    }
}

- (void)pauseButtonPressed
{
    CCLOG(@"Pause");
    // disable pause button while the pause menu is shown, since we want to avoid, that the pause button can be hit twice. 
    [self disableGameplayButtons];
    
    PauseScreen *pauseScreen = [[PauseScreen alloc] initWithGame:game];
    pauseScreen.delegate = self;
    [self addChild:pauseScreen z:10];
    [pauseScreen present];
    [[GameMechanics sharedGameMechanics] setGameState:GameStatePaused];
}

#pragma mark - Game Logic

- (void)executeGoOnAction
{
    [Store purchaseGoOnAction];
    knight.hitPoints = KNIGHT_HIT_POINTS;
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [NotificationBox presentNotificationBoxOnNode:self withText:@"Going on!" duration:1.f];
}

- (void)startSkipAheadMode
{
    BOOL successful = [Store purchaseSkipAheadAction];
    
    /* 
     Only enter the skip ahead mode if the purchase was successful (player had enough coins).
     This is checked previously, but we want to got sure that the player can never access this item
     without paying.
     */
    if (successful)
    {
        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:SCROLL_SPEED_SKIP_AHEAD];
        [[GameMechanics sharedGameMechanics] knight].invincible = TRUE;
        [self scheduleOnce: @selector(endSkipAheadMode) delay:5.f];
        
        // present a notification, to inform the user, that he is in skip ahead mode
        [NotificationBox presentNotificationBoxOnNode:self withText:@"Skip Ahead Mode!" duration:4.5f];
    }
}

- (void)endSkipAheadMode
{
    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:SCROLL_SPEED_DEFAULT];
    [[GameMechanics sharedGameMechanics] knight].invincible = FALSE;
}

- (void)presentMoreCoinsPopUpWithTarget:(id)target selector:(SEL)selector
{
    CCLOG(@"You need more coins!");
    NSArray *inGameStoreItems = [Store inGameStoreStoreItems];
    
    /* 
     The inGameStore is initialized with a callback method, which is called,
     once the closebutton is pressed.
     */
    inGameStore = [[InGameStore alloc] initWithStoreItems:inGameStoreItems backgroundImage:@"InGameStore_background.png" closeButtonImage:@"InGameStore_close.png" target:target selector:selector];
    /* The delegate adds a further callback, called when Items are purchased on the store, and we need to update our coin display */
    inGameStore.delegate = self;
    
    inGameStore.position = ccp(self.contentSize.width / 2, self.contentSize.height + 0.5 * inGameStore.contentSize.height);
    CGPoint targetPosition = ccp(self.contentSize.width / 2, self.contentSize.height /2);
    
    CCMoveTo *moveTo = [CCMoveTo actionWithDuration:1.f position:targetPosition];
    [self addChild:inGameStore z:MAX_INT];
    
    [inGameStore runAction:moveTo];
}


/* called when the 'More Coins Screen' has been closed, after previously beeing opened by
   attempting to buy a 'Skip Ahead' action */
- (void)returnedFromMoreCoinsScreenFromSkipAheadAction
{
    // hide store and resume game
    [inGameStore removeFromParent];
    [[GameMechanics sharedGameMechanics] setGameState:GameStateRunning];
    [self enableGamePlayButtons];
}

- (void)returnedFromMoreCoinsScreenFromGoOnAction
{
    [inGameStore removeFromParent];
    [self presentGoOnPopUp];
}

@end
