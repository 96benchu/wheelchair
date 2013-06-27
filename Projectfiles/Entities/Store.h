//
//  Store.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/23/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>
#import "StoreItem.h"

@interface Store : NSObject

// returns the available categories from the store
+ (NSArray *)categories;

// returns all available store items
+ (NSArray *)allStoreItems;

// returns the subset of store items which shall be presented in the in game store
+ (NSArray *)inGameStoreStoreItems;

// returns all available store items for the provided category
+ (NSArray *)storeItemsByCategory:(NSString *)category;

/* Fills the store with categories and items provided in the store Dictionary.
   Expected structure:
   {@"Category A": [Item1, Item2, Item3]
    @"Category B": [Item4, Item5, Item6] }*/
+ (void)setupWithStoreDictionary:(NSDictionary *)storeDictionary;

// returns the amount of available inAppCurrency
+ (int)availableAmountInAppCurrency;

// adds the provided amount of in App currency
+ (void)addInAppCurrency:(int)additionalCurrency;

// subtracts the provided amount of in App currency
+ (void)subtractInAppCurrency:(int)amountSubtraction;

// purchases the provided store item
+ (void)purchaseStoreItem:(StoreItem *)storeItem;

// this method allows checking if the player has enough coins to buy a 'Skip Ahead'
+(BOOL)hasSufficientFundsForSkipAheadAction;

// purchases a skip ahead action, if the player has enough coins. Returns TRUE if purchasing was successful.
+ (BOOL)purchaseSkipAheadAction;

// this method allows checking if the player has enough coins to buy a 'Go on'
+ (BOOL)hasSufficientFundsForGoOnAction;

// purchases a go on action
+ (BOOL)purchaseGoOnAction;
/*
   Lets the store set itself up with a default setting
 */
+ (void)setupDefault;

@end
