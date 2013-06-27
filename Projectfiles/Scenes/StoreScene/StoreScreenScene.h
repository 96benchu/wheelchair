//
//  StoreScene.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCScene.h"
#import "SWTableView.h"
#import "SWTableViewCell.h"
#import "StoreTableViewCell.h"


//Private class
@interface SWTableViewNodeCell : SWTableViewCell {
    CCNode *node;
}
@property (nonatomic, retain) CCNode *node;
@end


/**
 Screen for the In-App Purchase Store
 */
@interface StoreScreenScene : CCScene <SWTableViewDataSource, StoreDisplayNeedsUpdate>
{
    SWTableView *storeTableView;
    NSMutableArray *cells;
    CCLabelTTF *availableCashLabel;
}

// initializes the view with the store content
- (void)setupWithStoreContent;

@end
 