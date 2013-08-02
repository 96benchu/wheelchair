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
#import "Truth.h"
#import "Coins.h"

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
- (void)speedUpButtonPressed;
- (void)jumpButtonPressed;
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
       
        
        spikes = [[Spikes alloc] initWithSpikeImage];
        spikes.anchorPoint=ccp(0,0);
        //ramp = [[TutRamp alloc] initWithRampImage];

        //[self addChild:ramp];
        [self addChild:spikes];
        
        knight = [[Knight alloc] initWithKnightPicture];
        knight.anchorPoint = ccp(0,0);
        [self addChild:knight];
        spikes.anchorPoint=ccp(0,0);
        //ramp.anchorPoint=ccp(0,0);
        
        // add the health display
        healthDisplayNode = [[HealthDisplayNode alloc] initWithHealthImage:@"heart_filled.png" lostHealthImage:@"heart_empty.png" maxHealth:5];
        [hudNode addChild:healthDisplayNode z:MAX_INT-1];
        healthDisplayNode.position = ccp(screenCenter.x, self.contentSize.height - 18);
        
        // add scoreboard entry for coins
        //coinsDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:@"coin.png" fontFile:@"avenir.fnt"];
        //coinsDisplayNode.scoreStringFormat = @"%d";
        //coinsDisplayNode.position = ccp(20, self.contentSize.height - 26);
        //[hudNode addChild:coinsDisplayNode z:MAX_INT-1];
        
        // add scoreboard entry for in-app currency
        inAppCurrencyDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:@"coin.png" fontFile:@"avenir.fnt"];
        inAppCurrencyDisplayNode.scoreStringFormat = @"%d";
        inAppCurrencyDisplayNode.position = ccp(self.contentSize.width - 120, self.contentSize.height - 26);
        inAppCurrencyDisplayNode.score = [Store availableAmountInAppCurrency];
        [hudNode addChild:inAppCurrencyDisplayNode z:MAX_INT-1];
        
        // add scoreboard entry for points
        pointsDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:nil fontFile:@"avenir24.fnt"];
        pointsDisplayNode.position = ccp(10, self.contentSize.height - 40);
        pointsDisplayNode.scoreStringFormat = @"%d m";
        [hudNode addChild:pointsDisplayNode z:MAX_INT-1];
        //add scoreboard entry for spikes
        
        spikesDisplayNode = [[ScoreboardEntryNode alloc] initWithScoreImage:nil fontFile:@"avenir24.fnt"];
        spikesDisplayNode.position = ccp(70, self.contentSize.height - 40);
        spikesDisplayNode.scoreStringFormat = @"%d m";
        [hudNode addChild:spikesDisplayNode];
        spikesDisplayNode2 = [[ScoreboardEntryNode alloc] initWithScoreImage:nil fontFile:@"avenir24.fnt"];
        spikesDisplayNode2.position = ccp(140, self.contentSize.height - 40);
        spikesDisplayNode2.scoreStringFormat = @"%d m";
        [hudNode addChild:spikesDisplayNode2];
         
        
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
        //Nitro button
        nitro = [[NitroButton alloc] initWithButtonImage];
        arrowButton = [CCSprite spriteWithFile:@"button_arrowbutton.png"];
        arrowButton2 = [CCSprite spriteWithFile:@"button_arrowbutton.png"];
        [self addChild:nitro];
        nitro.anchorPoint = ccp(0,0);
        nitro.scale = .5;
        jumpButtonMenuItem = [CCMenuItemImage itemWithNormalImage:@"button-top.png" selectedImage:@"button-top.png" target:self selector:@selector(jumpButtonPressed)];
        jumpButtonMenuItem.position = ccp(-0,0);
        jumpButtonMenu = [CCMenu menuWithItems:jumpButtonMenuItem, nil];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        jumpButtonMenu.position = ccp(0,49);
        jumpButtonMenu.scale = .5;
        [hudNode addChild:jumpButtonMenu];
        // add the enemy cache containing all spawned enemies
        [self addChild:[EnemyCache node]];
        //speedUpButton        
        // setup a new gaming session
        [self resetGame];
        speedUp =18;
        counter = 0;
        counter2 = 29;
        mult = 10;
        cap=275;
        counter3 = 0;
        num = 3;
        counter4=0;
        counter5=3;
        counter6=0;
        counter7 = 59;
        spawnRate = 160;
        recent = false;
        nitroOn = false;
        recent2 = false;
        counter8 = 0;
        capDivider = 30;
        counter9= 0;
        recent3 = false;
        recent4= true;
        counter10= 0;
        recent5=false;
        recent31=false;
        text1= false;
        text2=false;
        text3=false;
        text31=false;
        text4=false;
        text41=false;
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
- (void)jumpButtonPressed
{
    [knight jump];
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
    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:0];
    
    /* setup initial values */
    
    // setup knight
    knight.position = ccp(125,20);
    knight.zOrder = 10;
    knight.scale = .75;
    knight.hitPoints = KNIGHT_HIT_POINTS;
    
    // setup HUD
    healthDisplayNode.health = knight.hitPoints;
    coinsDisplayNode.score = game.score;
    pointsDisplayNode.score = game.meters;
    //setup spikes
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    spikes.position = ccp(0,125);
    spikes.zOrder = 11;
    spikes.rotation = 106;
    nitro.position = ccp(screenHeight-screenHeight/3.25,90);
    spikes.velocity = ccp(0,0);
    arrowButton.position = ccp(jumpButtonMenu.position.x+screenHeight/4, jumpButtonMenu.position.y+142);
    arrowButton2.position = ccp(nitro.position.x+43, nitro.position.y+100);
    arrowButton.rotation = 90;
    arrowButton2.rotation = 90;
    arrowButton.visible = YES;
    arrowButton2.visible = YES;
    arrowButton2.scale = .3;
    arrowButton.scale=.3;

    arrowButton.opacity = 0;
    arrowButton2.opacity = 0;
    label = [CCLabelTTF labelWithString:@"Scroll right to speed up to avoid spikes following you" fontName:@"Helvetica" fontSize:14];
    label2 = [CCLabelTTF labelWithString:@"Swipe faster on ramps!" fontName:@"Helvetica" fontSize:14];
    label3 = [CCLabelTTF labelWithString:@"Press the jump button to jump over barrels" fontName:@"Helvetica" fontSize:14];
    label5 = [CCLabelTTF labelWithString:@"Use the nitro button in emergency situations" fontName:@"Helvetica" fontSize:14];
    label6 = [CCLabelTTF labelWithString:@"Rollout!" fontName:@"Helvetica" fontSize:14];
    jumpLabel = [CCLabelTTF labelWithString:@"Jump" fontName:@"Helvetica" fontSize:14];
    nitroLabel = [CCLabelTTF labelWithString:@"Dont" fontName:@"MarkerFelt-Thin" fontSize:14];
    nitroLabel2 = [CCLabelTTF labelWithString:@"Touch" fontName:@"MarkerFelt-Thin" fontSize:14];
    [self addChild: label];
    [self addChild: label2];
    [self addChild: label3];
    [self addChild: label5];
    [self addChild: label6];
    [self addChild: arrowButton];
    [self addChild: arrowButton2];
    [self addChild: jumpLabel];
    [self addChild: nitroLabel];
    [self addChild: nitroLabel2];
    label.visible = NO;
    label2.visible = NO;
    label3.visible = NO;
    label5.visible = NO;
    label6.visible = NO;
    label.color = ccc3(0,0,0);
    label.position = ccp(screenHeight/2,screenWidth-screenWidth/3);
    label2.color = ccc3(0,0,0);
    label2.position = ccp(screenHeight/2,screenWidth-screenWidth/3);
    label3.color = ccc3(0,0,0);
    label3.position = ccp(screenHeight/2,screenWidth-screenWidth/3);
    label5.color = ccc3(0,0,0);
    label5.position = ccp(screenHeight/2,screenWidth-screenWidth/3);
    label6.color = ccc3(0,0,0);
    label6.position = ccp(screenHeight/2,screenWidth-screenWidth/3);
    jumpLabel.color = ccc3(0,0,0);
    nitroLabel.color= ccc3(0,0,0);
    nitroLabel2.color = ccc3(0,0,0);
    jumpLabel.position = ccp(jumpButtonMenuItem.position.x+screenHeight/4,jumpButtonMenuItem.position.y+130);
    nitroLabel.position =ccp(nitro.position.x+42, nitro.position.y+44);
    nitroLabel2.position =ccp(nitro.position.x+42, nitro.position.y+30);
    label.opacity = 0;
    label2.opacity = 0;
    label3.opacity = 0;
    label5.opacity = 0;
    label6.opacity = 0;
    
   //ramp.position = ccp(-500,-500);

    //set spwan rate for monsters
   //[[GameMechanics sharedGameMechanics] setSpawnRate:400 forMonsterType:[Ramps class]];
    //[[GameMechanics sharedGameMechanics] setSpawnRate:250 forMonsterType:[Coins class]];
    
    // set gravity (used for jumps)
    [[GameMechanics sharedGameMechanics] setWorldGravity:ccp(0.f, -900.f)];
    
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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
   
    
    // distance depends on the current scrolling speed
    gainedDistance2 += ((int) (delta*[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]));
    gainedDistance = (int) ( [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]);
    game.meters = (int) ((gainedDistance));
    // update the score display
    pointsDisplayNode.score = game.meters;
    coinsDisplayNode.score = game.score;
    healthDisplayNode.health = knight.hitPoints;
    spikesDisplayNode.score = gainedDistance2/10;
    spikesDisplayNode2.score = spikes.velocity.x;
    Truth* data = [Truth sharedData];
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseAny];
    CGRect buttonArea = [nitro boundingBox];
    //nitro
    if(gainedDistance2>150000)
    {
        NSLog(@"ydone");
        
        counter2++;
        counter3++;
        counter4++;
        counter8++;
    }
    counter++;
    counter7++;
    counter9++;
    if(text1 == false)
    {
        label.visible= YES;
        [label runAction:[CCFadeIn actionWithDuration:.5]];
        text1=true;
    }
    if(gainedDistance2>= 500 && recent5==false)
    {
        
        [label runAction:[CCFadeOut actionWithDuration:.5]];
        recent5 = true;
    }
    //[self tutorialText1];
    if((gainedDistance2>=1000) && (recent3 ==false))
    {
        label2.visible=YES;
        [label2 runAction:[CCFadeIn actionWithDuration:.5]];

        
        //int rand = arc4random()%25+160;
        [[GameMechanics sharedGameMechanics] setSpawnRate:101 forMonsterType:[Ramps class]];
        recent3 = true;
    }
    if(gainedDistance2>=1500 && recent31==false)
    {
        
        //[arrowButton runAction:[CCFadeOut actionWithDuration:.25]];
        [label2 runAction:[CCFadeOut actionWithDuration:.5]];
        recent31=true;
    }
    if(gainedDistance2>=2200  && text2 == false)
    {
        arrowButton.visible = YES;
        [arrowButton runAction:[CCFadeIn actionWithDuration:.5]];
        [[GameMechanics sharedGameMechanics] setSpawnRate:220 forMonsterType:[Box1 class]];
        label3.visible = YES;
        [label3 runAction:[CCFadeIn actionWithDuration:.5]];
        text2 = true;
    }
    if(gainedDistance2>=2800 && text21==false)
    {
        [label3 runAction:[CCFadeOut actionWithDuration:.5]];
        [arrowButton runAction:[CCFadeOut actionWithDuration:.5]];
        text21=TRUE;
        
    }
    if(gainedDistance2 >=8000 &&text3 == false)
    {
        label5.visible = YES;
        arrowButton.visible = YES;
        [arrowButton2 runAction:[CCFadeIn actionWithDuration:.5]];
        [label5 runAction:[CCFadeIn actionWithDuration:.5]];
        text3=true;
    }
    if(gainedDistance2 >= 9500 && text31==false)
    {
        [label5 runAction:[CCFadeOut actionWithDuration:.5]];
        [arrowButton2 runAction:[CCFadeOut actionWithDuration:.55]];
        
        text31 = true;
    }
    if(gainedDistance2>= 3200 && text4==false)
    {
        label6.visible=YES;
        [label6 runAction:[CCFadeIn actionWithDuration:.5]];
        text4=true;
    }
    if(gainedDistance2>=3800 && text41==false)
    {
        [label6 runAction:[CCFadeOut actionWithDuration:.5]];
        text41=true;
        
    }
    //[ramp detectCol:knight.position];
    //ramp.velocity = ccp(-[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX], ramp.velocity.y);
    if(CGRectContainsPoint(buttonArea, pos))
    {
       
        if(knight.fuel > 0)
        {
            
            if((!nitroOn) && (recent2 == false))
            {
                if(knight.fuel > 500)
                {
                recent2 = true;
                nitroOn = true;
                knight.fuel -= 250;
                if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] <=0)
                {
                    
                    if(knight.position.y >20 && data.onRamp == false)
                    {
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:300];
                    }
                    else
                    {
                        
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:200];
                    }
                }
                else
                {
                    if(knight.position.y > 20 && data.onRamp == false)
                    {
                       
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+400];
                    }
                    else
                    {
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+200];
                    }
                }
                if(([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]>=20))
                {
                    if(data.onRamp == TRUE)
                    {
                        if(spikes.velocity.x > 0)
                        {
                            if(spikes.velocity.x > 10)
                            {
                                spikes.velocity = ccp(0, spikes.velocity.y);
                            }
                            else
                            {
                                spikes.velocity = ccp(-5, spikes.velocity.y);
                            }
                        }
                        else
                        {
                            spikes.velocity = ccp(spikes.velocity.x - 8, spikes.velocity.y);
                        }
                    }
                    else
                    {
                        if(spikes.velocity.x > 0)
                        {
                            spikes.velocity = ccp(-20, spikes.velocity.y);
                        }
                        else
                        {
                            spikes.velocity = ccp(spikes.velocity.x - 20, spikes.velocity.y);
                        }
                    }
                }
                else
                {
                    if(data.onRamp == true)
                    {
                        spikes.velocity = ccp(spikes.velocity.x - 5, spikes.velocity.y);
                    }
                    else
                    {
                        spikes.velocity = ccp(spikes.velocity.x - 7, spikes.velocity.y);
                    }
                }
                }
            }
            else
            {
                //NSLog(@"out Of fuel");
            }
            
            if(nitroOn || recent2 || knight.fuel < 250)
            {
                
                knight.fuel -= 10;
                nitroOn = true;
                
                    if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] >0)
                    {
                        //NSLog(@"WORKS");
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+10];
                    }
                    else
                    {
                       // NSLog(@"WORKS");
                        [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+30];
                    }
                
                if(([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]>=20))
                {
                    if(spikes.velocity.x > 0)
                    {
                        spikes.velocity = ccp(spikes.velocity.x - .5, spikes.velocity.y);
                    }
                    else
                    {
                        spikes.velocity = ccp(spikes.velocity.x - .5, spikes.velocity.y);
                    }
                }
        
                //initial nitro
             
            }
        }
    }
    else
    {
        nitroOn = false;
    }
    if(knight.fuel < 0)
    {
        knight.fuel = 0;
    }
    if(recent2 == true)
    {
        counter6++;
        if(counter6 >= 180*((1/delta)/60))
        {
            recent2 = false;
            counter6=0;
        }
    }
   // NSLog(nitroOn ? @"Yes" : @"No");
    
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
            case KKSwipeGestureDirectionDown:
                //if falling behind

                    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]+cap/8];
                

                //NSLog([NSString stringWithFormat:@"%i",counter5]);
                //failsafe
                if(knight.velocity.x>0)
                {
                    knight.velocity = CGPointMake(0, knight.velocity.y);
                }
                if(spikes.position.x>= -151)
                {
                    if(spikes.velocity.x>=-40)
                    {
                        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]>30)
                        {
                            if(spikes.velocity.x < 0)
                            {
                                spikes.velocity = ccp(spikes.velocity.x-6.5,spikes.velocity.y);
                            }
                            else
                            {
                                spikes.velocity = ccp(spikes.velocity.x -8,spikes.velocity.y);
                            }
                        }
                        else
                        {
                            spikes.velocity = ccp(spikes.velocity.x-1, spikes.velocity.y);
                        }
                    }
                }
                else
                {
                    spikes.position = ccp(-250,125);

                }
                break;
                
            case KKSwipeGestureDirectionUp:
                [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-30];
                break;
            case KKSwipeGestureDirectionRight:

                break;
            default:
                break;
        }
    }
    
    //else if([input anyTouchEndedThisFrame])
    //{
    //    [knight jump];
    //}
    if (knight.hitPoints <= 0)
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
    
    /*
    CGSize spriteSize2 = ramp.size;
    double x2 = spriteSize2.width;
    double y2 = spriteSize2.height;
    double z2 = y2/x2;
    double diffx2 = knight.position.x - ramp.position.x;
    counter10++;
    if(ramp.col)
    {
        //knight.rotation = -atan(z2)*(180/M_PI);
        //knight.position = ccp(knight.position.x, diffx2*z2+20);
        //if(counter10 >= 15*((1/delta)/60))
        {
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-50];
            counter10=0;
        }
        recent4 = true;
    }
    
    if(recent4 == true)
    {
        
        if(data.onRamp==false || ramp.col)
        {
            knight.rotation = 0;
            knight.velocity = ccp(knight.velocity.x, [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]*z2+knight.velocity.y+900.f);
            recent4 = false;
        }
        
    }
     */
    CGSize spriteSize = data.sprite;
    double x = spriteSize.width;
    double y = spriteSize.height;
    double z = y/x;
    double diffX = knight.position.x - data.pos.x;
    if(data.onRamp== true)
    {
        knight.rotation = -atan(z)*(180/M_PI);

       // NSLog([NSString stringWithFormat:@"%f",atan(z)]);

        //NSLog([NSString stringWithFormat:@"%i",diffX]);
        //NSLog(ramp.col ? @"Yes" : @"No");
        knight.position = ccp(knight.position.x, diffX*z+20);
        if(((counter>=5*(1/delta)/60) || (counter >=10*(1/delta)/60) || (counter >=15*(1/delta)/60)))
        {
            //decreasbackground speed
            double frac = 275/(275+(cap-275)/4);
            if(counter>=15*((1/delta)/60))
            {
                if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
                {
                    [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]*frac];
                }
            }
            if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
            {
                [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-cap/(capDivider+40)];
            }
            if(spikes.velocity.x<0)
            {
                spikes.velocity = ccp(spikes.velocity.x + speedUp/32, spikes.velocity.y);
            }
            else
            {
                spikes.velocity = ccp(spikes.velocity.x + speedUp/40, spikes.velocity.y);
            }
            recent = true;
            
        }
        recent = true;
    }
    //increase speed after leaving ramp
   // NSLog(recent ? @"Yes" : @"No");
    if(recent == true)
    {
        
        if(data.onRamp==false)
        {
            
            knight.rotation = 0;
            knight.velocity = ccp(knight.velocity.x, [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]*z+knight.velocity.y+950.f);
            recent = false;
            data.recent = recent;
        }
    }
    //decrease background speed
    //NSLog(ramp.col ? @"Yes" : @"No");
    if(counter >= 15*((1/delta)/60))
    {
        if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] > 0)
        {
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-cap/capDivider];
        }
        // if there's a ramp

        else
        {
            if(data.onRamp == false)
            {
                [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:0];
            }
            else
            {
                //[[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]-cap/65];
            }
        }
        counter = 0;
        if(([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]) > cap)
        {
            double decrease = [[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] - cap;
            [[GameMechanics sharedGameMechanics] setBackGroundScrollSpeedX:[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX] - decrease/1.75];
        }
        if(spikes.velocity.x <30)
        {
            if(spikes.velocity.x <0)
            {
                spikes.velocity = ccp(spikes.velocity.x + speedUp/7, spikes.velocity.y);
            }
            else
            {
                spikes.velocity = ccp(spikes.velocity.x + speedUp/9, spikes.velocity.y);
            }
        }
        
    }
     
    //spikes moving

    //determines if spikes moving and gradual speedUp
    
    if(counter2>=30*((1/delta)/60))
    {
        
        
       /*NSLog([NSString stringWithFormat:@"%i",counter5]);
        //spike speedUp
        if(counter5> speedUp)
           {
               if(spikes.position.x> -300)
               {
                   if(spikes.velocity.x>=0)
                   {
                       if([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]>30)
                       {
                           if(spikes.position.x < 50)
                           {
                               spikes.velocity = ccp(((speedUp)-counter5)*2.5+spikes.velocity.x,spikes.velocity.y);
                           }
                           else
                           {
                               spikes.velocity = ccp(((speedUp)*1/2-counter5)*2.5,spikes.velocity.y);
                           }
                       }
                       else
                       {
                           spikes.velocity = ccp(spikes.velocity.x+((speedUp)*2/3-counter5)*2.5, spikes.velocity.y);
                       }
                   }
               }
               else
               {
                   spikes.position = ccp(-300,300);
                   spikes.velocity = ccp(0,0);
               }
           }
        //spike slowdown
        else if(speedUp > counter5)
        {
            if(spikes.velocity.x<30)
            {
                if(spikes.position.x < 50)
                {
                    spikes.velocity = ccp((speedUp-counter5)*2+spikes.velocity.x,spikes.velocity.y);
                }
                else
                {
                    spikes.velocity = ccp(((speedUp)*1/2-counter5)*2+spikes.velocity.x,spikes.velocity.y);
                }
            }
        }*/
        //if on ramp and very slow, in case of stalling on ramp and no movement
        if(([[GameMechanics sharedGameMechanics] backGroundScrollSpeedX]<=30) && (data.onRamp==true))
        {
            if(spikes.velocity.x <0)
            {
                if(spikes.position.x < 50)
                {
                    spikes.velocity = ccp(5,spikes.velocity.y);
                }
                else
                {
                    spikes.velocity = ccp(3 ,spikes.velocity.y);
                }
            }
            else
            {
                if(spikes.position.x < 50)
                {
                    spikes.velocity = ccp(4 +spikes.velocity.x,spikes.velocity.y);
                }
                else
                {
                    spikes.velocity = ccp(2 +spikes.velocity.x,spikes.velocity.y);
                }
            }
        }
        //gradual speedup
        if(speedUp<24)
        {
            speedUp+=.025;
        }
        
        counter5=0;
    }
    if(counter2 >= 30*((1/delta)/60))
    {
        if(cap<500)
        {
            cap+=1;
        }
        counter2=0;	
    }
    //large speedUp
    //NSLog(@"%i", counter3);
    //NSLog(@"%f", delta);
    if(counter3 >= 600*((1/delta)/60))
    {
        //NSLog(@"Yeaah");
        if(speedUp<20)
        {
            speedUp+=4;
        }
        if(cap<500)
        {
            cap+=40;
        }
        counter3=0;
        if(spawnRate>100)
        {
            spawnRate = spawnRate - 40;
        }
        counter3 = 0;

    }

    
    //nightmare
    if(counter8 >= 3600*((1/delta)/60))
    {
        cap = 650;
        speedUp = 24;
        capDivider = 60;
    }
    //failsafe
    if(spikes.position.x<-250)
    {
        //NSLog(@"WHY DONT U WORK");
        spikes.position = ccp(-250, 125);
    }
    //ram velocity
    data.scrollSpeed = -1*[[GameMechanics sharedGameMechanics] backGroundScrollSpeedX];
    if(data.hit)
    {
        
        [knight gotHit];

    }
    
    if(knight.position.x-50 < spikes.position.x)
    {
        knight.hitPoints--;
        knight.hitPoints--;
        knight.hitPoints--;
        knight.hitPoints--;
        knight.hitPoints--;
        knight.hitPoints--;
    }
    data.gainedDistance = gainedDistance2/10;
    if(counter7>=60*((1/delta)/60))
    {
        if(counter8<4800*((1/delta)/60))
        {
            if(recent3)
            {
                //NSLog(@"spawnwdd");
                int rand = arc4random()%15+240;
                [[GameMechanics sharedGameMechanics] setSpawnRate:rand forMonsterType:[Ramps class]];

            }
            if(text2)
            {
                int rand = arc4random()%15+65;
                 [[GameMechanics sharedGameMechanics] setSpawnRate:rand forMonsterType:[Box1 class]];
                if(gainedDistance2 >= 1500)
                {
                    int rand = arc4random()%35+130;
                    [[GameMechanics sharedGameMechanics] setSpawnRate:rand forMonsterType:[Box1 class]];
                }
            }
    
        
        }
        else
        {
            int rand = arc4random()%30+30;
            //[[GameMechanics sharedGameMechanics] setSpawnRate:rand forMonsterType:[Box1 class]];
        }
        counter7 = 0;
    }
    knight.coins += data.collect;
    //NSLog(@"Value of hello = %i", counter8);
   //NSLog(@"Value of hello = %f", cap);
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
