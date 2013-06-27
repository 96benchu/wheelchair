//
//  LeaderBoardTableViewCell.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "SWTableViewCell.h"
#import "StoreItem.h"
#import "PopUp.h"
#import "CCControlButton.h"


// this protocol is used by the StoreScreenScene, to be informed whenever items are purchased by any of the cells
@protocol StoreDisplayNeedsUpdate <NSObject>

// method is called, whenever a store display update is necessary
- (void)storeDisplayNeedsUpdate;

@end

@interface StoreTableViewCell : SWTableViewCell
{
    CCLabelTTF *storeItemLabel;
    CCLabelTTF *storeItemDetailDescriptionLabel;
    CCLabelTTF *costLabel;
    
    CCSprite *storeItemThumbnail;
    CCSprite *coinIcon;
    CCSprite *backgroundSprite;
    
    CCControlButton *purchaseButton;
    PopUp *popUp;
}

@property (nonatomic, readonly) StoreItem *storeItem;
@property (nonatomic, weak) id<StoreDisplayNeedsUpdate> delegate;

- (void)setupWithStoreItem:(StoreItem *)storeItem;

// cell cloning method
+ (StoreTableViewCell *)cellWithStoreTableViewCell:(StoreTableViewCell *)cell;

@end
