//
//  StoreTableViewHeaderCell.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/24/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "SWTableViewCell.h"

@interface StoreTableViewHeaderCell : SWTableViewCell
{
    CCLabelTTF *storeItemLabel;
    CCSprite *backgroundSprite;
}


@property (nonatomic, readonly) NSString *title;

- (void)setupWithTitle:(NSString *)title;

+ (StoreTableViewHeaderCell *)cellWithStoreTableViewHeaderCell:(StoreTableViewHeaderCell *)storeTableViewHeaderCell;

@end
