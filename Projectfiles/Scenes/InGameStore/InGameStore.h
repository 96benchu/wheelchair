//
//  InGameStore.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/8/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCLayer.h"
#import "StoreTableViewCell.h"
#import "PopUp.h"

/*
 InGameStore, mostly presented as popup.
 In the template game this component is used for the 'More Coins' Popup
 */

@interface InGameStore : CCLayer
{
    CCMenu *closeButtonMenu;
    CCSprite *backgroundSprite;
    CCMenu *storeMenu;
    // variable is used to remember the store item which shall be purchased
    StoreItem *purchasedStoreItem;
    PopUp *popUp;
}

/*
 The store items passed to this method should have an inGameStoreImageFile (see 'StoreItem.h')
 */
- (id)initWithStoreItems:(NSArray *)storeItems backgroundImage:(NSString *)backgroundImageFileName closeButtonImage:(NSString *)closeButtonImage target:(id)target selector:(SEL)selector;

// method is called, whenever a store display / coin display update is necessary
@property (nonatomic, weak) id<StoreDisplayNeedsUpdate> delegate;

@end
