//
//  InGameStore.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/8/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "InGameStore.h"
#import "StoreItem.h"
#import "CoinPurchaseStoreItem.h"
#import "Store.h"
#import "PopupProvider.h"
#import "CCControlButton.h"

@implementation InGameStore

- (id)initWithStoreItems:(NSArray *)storeItems backgroundImage:(NSString *)backgroundImageFileName closeButtonImage:(NSString *)closeButtonImage target:(id)target selector:(SEL)selector
{
    self = [super init];
    
    if (self)
    {
        /* Add background Image */
        backgroundSprite = [CCSprite spriteWithFile:backgroundImageFileName];
        [self addChild:backgroundSprite];
        self.contentSize = backgroundSprite.contentSize;
        
        /* Add close button*/
        CCSprite *closeButton = [CCSprite spriteWithFile:closeButtonImage];
        CCMenuItemSprite *closeButtonMenuItem = [CCMenuItemSprite itemWithNormalSprite:closeButton selectedSprite:nil block:^(id sender) {
                [target performSelector:selector];
        }];
        closeButtonMenu = [CCMenu menuWithItems:closeButtonMenuItem, nil];
        closeButtonMenu.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [self addChild:closeButtonMenu];
        
        /* Add store items */
        NSMutableArray *menuEntries = [[NSMutableArray alloc] init];
        
        for (unsigned int i = 0; i < [storeItems count]; i++)
        {
            StoreItem *currentStoreItem = [storeItems objectAtIndex:i];
            // check that we have an inGameStoreImageFile
            NSAssert(currentStoreItem.inGameStoreImageFile, @"StoreItem without an inGameStoreImageFile cannot be added to an inGameStore");
            CCSprite *itemSprite = [CCSprite spriteWithFile:currentStoreItem.inGameStoreImageFile];
            
            // add a menuItem for each menuButton
            CCMenuItemSprite *menuItem = [CCMenuItemSprite itemWithNormalSprite:itemSprite selectedSprite:nil block:^(id sender)
            {
                // remember the item we are buying for the callback method
                purchasedStoreItem = currentStoreItem;
                
                if ([currentStoreItem isKindOfClass:[CoinPurchaseStoreItem class]])
                {
                    /* if this is a coinPurchaseStoreItem, it means we need to do an In-App-Purchase.
                       Other items are simply bought with In-App-Currency and do not require an In-App-Purchase */
                    CoinPurchaseStoreItem *coinPurchaseItem = (CoinPurchaseStoreItem *) currentStoreItem;
                    [MGWU testBuyProduct:coinPurchaseItem.productID withCallback:@selector(boughtProduct:) onTarget:self];
                }
            }];
            [menuEntries addObject:menuItem];
        }
        storeMenu = [CCMenu menuWithArray:menuEntries];
        storeMenu.contentSize = self.contentSize;
        storeMenu.position = ccp(0, 0);
        [storeMenu alignItemsHorizontally];
        
        [self addChild:storeMenu];
    }
    
    return self;
}


- (void)boughtProduct:(NSString *)response
{
    if (response != nil)
    {
        // product has been purchased succesfully
        if ([purchasedStoreItem isKindOfClass:[CoinPurchaseStoreItem class]])
        {
            CoinPurchaseStoreItem *storeItem = (CoinPurchaseStoreItem *) purchasedStoreItem;
            [Store purchaseStoreItem:storeItem];
            [self.delegate storeDisplayNeedsUpdate];
            
            // disable menues, while the popup is displayed
            storeMenu.enabled = FALSE;
            closeButtonMenu.enabled = FALSE;
            
            NSString *popUpMessage = [NSString stringWithFormat:@"You successfully bought \n%@", storeItem.title];
            popUp = [PopupProvider presentPopUpWithContentString:popUpMessage target:self selector:@selector(popUpButtonClicked:) buttonTitles:@[@"OK"]];
        }
    }
}

- (void)popUpButtonClicked:(CCControlButton *)sender
{
    CCLOG(@"Button clicked.");
    if (sender.tag == 0)
    {
        // OK button selcted
        [popUp dismiss];
        
        // enable menues again
        storeMenu.enabled = TRUE;
        closeButtonMenu.enabled = TRUE;
    }
}

@end
