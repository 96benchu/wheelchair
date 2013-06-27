//
//  HealthDisplayNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/16/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "HealthDisplayNode.h"

@implementation HealthDisplayNode

@synthesize health = _health;

- (id)initWithHealthImage:(NSString*)healthImg lostHealthImage:(NSString*)lostHealthImg maxHealth:(int)mHealth
{
    self = [super init];
    
    if (self)
    {
        healthImage = healthImg;
        lostHealthImage = lostHealthImg;
        maxHealth = mHealth;
        healthSprites = [[NSMutableArray alloc] init];
        
        // load textures for both healthImage and lostHealthImage
        healthTexture = [[CCTextureCache sharedTextureCache] addImage:healthImage];
        lostHealthTexture = [[CCTextureCache sharedTextureCache] addImage:lostHealthImage];
        
        // create Sprites for the total available health 
        int xPos = 0;
        for (int i = 0; i < maxHealth; i++)
        {
            CCSprite *healthSprite = [CCSprite spriteWithTexture:healthTexture];
            healthSprite.anchorPoint = ccp(0,1);
            healthSprite.position = ccp(xPos,healthSprite.contentSize.height);
            xPos += healthSprite.contentSize.width;
            [self addChild:healthSprite];
            [healthSprites addObject:healthSprite];
        }
        
        self.anchorPoint = ccp(0.5, 0.5);
        self.contentSize = CGSizeMake(xPos, healthTexture.contentSize.height);
    }
    
    return self;
}

- (void)setHealth:(int)health
{
    //update UI according to the new amount of health
    if (health != _health)
    {
        _health = health;
        
        for (int i = 0; i < maxHealth; i++)
        {
            CCSprite *healthSprite = [healthSprites objectAtIndex:i];

            if (i < health)
            {
                // activate all health images for the available health
                if (![healthSprite.texture isEqual:healthTexture])
                {
                    healthSprite.texture = healthTexture;
                }
            } else
            {
                // deactivate health images for lost healthes
                if (![healthSprite.texture isEqual:lostHealthTexture])
                {
                    healthSprite.texture = lostHealthTexture;
                }
            }
        }
    }
}

@end
