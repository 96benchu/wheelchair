//
//  CoinPurchaseStoreItem.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 6/3/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "StoreItem.h"

/* 
 A StoreItem which allows purchasing virtual currency.
 */

@interface CoinPurchaseStoreItem : StoreItem

@property (nonatomic, strong) NSString *productID;

// defines how many coins a player gets when purchasing this article
@property (nonatomic, assign) int coinValue;

@end
