//
//  StoreScene.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "StoreScreenScene.h"
#import "StoreTableViewCell.h"
#import "StoreTableViewHeaderCell.h"
#import "Store.h"
#import "CCMenuNoSwallow.h"
#import "PopupProvider.h"
#import "CCControlButton.h"
#import "STYLES.h"
#import "StyleManager.h"
#import "GameplayLayer.h"

#define ROW_HEIGHT 39
#define ROW_HEIGHT_HEADER 20
#define SECTION_INDEX 1
#define TABLE_WIDTH 480

@implementation StoreScreenScene



-(id)init
{
    self = [super init];
    CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
    
    [self addChild:background];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    background.position = ccp(screenHeight*2/3, screenWidth/2);
   CCLabelTTF *upgrades1 = [CCLabelTTF labelWithString:@"upgrade" fontName:@"HelveticaNeue-Light" fontSize:30];
    CCLabelTTF *upgrades2 = [CCLabelTTF labelWithString:@"upgrade" fontName:@"HelveticaNeue-Light" fontSize:30];
    upgrades1.color = ccBLACK;
    upgrades2.color = ccBLACK;
    CCMenuItemFont* upgrade1 = [CCMenuItemFont itemWithLabel:upgrades1 target:self selector:@selector(upgrade)];
    
    CCMenuItemFont* upgrade2 = [CCMenuItemFont itemWithLabel:upgrades2 target:self selector:@selector(upgrade2)];

    if([[NSUserDefaults standardUserDefaults] objectForKey:@"nitroUpgrade"]==nil)
    {
        NSNumber *numb = [NSNumber numberWithDouble:0];
        [[NSUserDefaults standardUserDefaults] setObject:numb forKey:@"nitroUpgrade"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"wheelUpgrade"]==nil)
    {
        NSNumber *numb = [NSNumber numberWithDouble:0];
        [[NSUserDefaults standardUserDefaults] setObject:numb forKey:@"wheelUpgrade"];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"coins"]==nil)
    {
        NSNumber *numb = [NSNumber numberWithDouble:0];
        [[NSUserDefaults standardUserDefaults] setObject:numb forKey:@"coins"];
    }
    NSNumber *nitroUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:@"nitroUpgrade"];
    NSNumber *wheelUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:@"wheelUpgrade"];
    NSNumber *coins = [[NSUserDefaults standardUserDefaults] objectForKey:@"coins"];
    NSString* nitro = [NSString stringWithFormat:@"level %@", nitroUpgrade];
    upgraded1 = [CCLabelTTF labelWithString:nitro fontName:@"HelveticaNeue-Light" fontSize:40];
    upgraded1.color = ccc3(0,0,0);
    NSString* wheel = [NSString stringWithFormat:@"level %@", wheelUpgrade];
    upgraded2 = [CCLabelTTF labelWithString:wheel fontName:@"HelveticaNeue-Light" fontSize:40];
    upgraded2.color = ccc3(0,0,0);
    NSString* coin = [NSString stringWithFormat:@"%@ coins", coins];
    
    coinCount = [CCLabelTTF labelWithString:coin fontName:@"HelveticaNeue-Light" fontSize:40];
    coinCount.color = ccc3(0,0,0);
    [self addChild:upgraded1];
    [self addChild:upgraded2];
    //[self addChild:upgrade2];
    //[self addChild:upgrade1];
    [self addChild:coinCount];
    CCMenu *startMenu = [CCMenu menuWithItems:upgrade1, upgrade2,nil];
    upgrade1.position = ccp(screenHeight/3, screenWidth*3/4);
    upgrade2.position = ccp(screenHeight*2/3, screenWidth*3/4);
    upgraded1.position = ccp(screenHeight/3, screenWidth*3/4-50);
    upgraded2.position = ccp(screenHeight*2/3, screenWidth*3/4-50);
    startMenu.anchorPoint = ccp(0,0);
    startMenu.position = ccp(0,0);
    [self addChild:startMenu z:90001];
    coinCount.position = ccp(screenHeight/2, screenWidth*5/6);
    [self scheduleUpdate];
    return self;

}

- (void) update:(ccTime)delta
{
    NSNumber *nitroUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:@"nitroUpgrade"];
    NSNumber *wheelUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:@"wheelUpgrade"];
    NSNumber *coins = [[NSUserDefaults standardUserDefaults] objectForKey:@"coins"];
    NSString* nitro = [NSString stringWithFormat:@"level %@", nitroUpgrade];
    upgraded1 = [CCLabelTTF labelWithString:nitro fontName:@"HelveticaNeue-Light" fontSize:40];
    NSString* wheel = [NSString stringWithFormat:@"level %@", wheelUpgrade];
    upgraded2 = [CCLabelTTF labelWithString:wheel fontName:@"HelveticaNeue-Light" fontSize:40];
    NSString* coin = [NSString stringWithFormat:@"%@ coins", coins];
    coinCount = [CCLabelTTF labelWithString:coin fontName:@"HelveticaNeue-Light" fontSize:40];
    
}

-(void)upgrade
{
    NSNumber *nitroUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:@"nitroUpgrade"];
    double upgrade = [nitroUpgrade doubleValue];
    NSNumber *coins = [[NSUserDefaults standardUserDefaults] objectForKey:@"coins"];
    int coin = [coins doubleValue];
    if(coin>= (upgrade*upgrade)*300 && upgrade<5)
    {
        upgrade+=1;
        coin-=upgrade*upgrade*300;
    }
    NSNumber *upgraded = [NSNumber numberWithDouble:upgrade];
    coins = [NSNumber numberWithInt:coin];
    [[NSUserDefaults standardUserDefaults] setObject:upgraded forKey:@"nitroUpgrade"];
    [[NSUserDefaults standardUserDefaults] setObject:coins forKey:@"coins"];
    
}
-(void)upgrade2
{
    NSNumber *nitroUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:@"wheelUpgrade"];
    double upgrade = [nitroUpgrade doubleValue];
    NSNumber *coins = [[NSUserDefaults standardUserDefaults] objectForKey:@"coins"];
    int coin = [coins doubleValue];
    if(coin>= (upgrade*upgrade)*300 && upgrade<5)
    {
        upgrade+=1;
        coin-=upgrade*upgrade*300;
    }
    NSNumber *upgraded = [NSNumber numberWithDouble:upgrade];
    coins = [NSNumber numberWithInt:coin];
    [[NSUserDefaults standardUserDefaults] setObject:upgraded forKey:@"wheelUpgrade"];
    [[NSUserDefaults standardUserDefaults] setObject:coins forKey:@"coins"];
}
@end
