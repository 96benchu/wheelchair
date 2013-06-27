//
//  Store.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/23/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "Store.h"
#import "StoreItem.h"
#import "VirtualCurrencyStoreItem.h"
#import "CoinPurchaseStoreItem.h"

#define KEY_IN_APP_CURRENCY @"inAppCurrency"

/*
 This class represents the store containing purchasable items.
 Use this class to access all store items.
 */
NSDictionary *storeContent;

/*
 The subset of all store items, that shall be presented in the in game store.
 */
NSMutableArray *inGameStoreItems;

int availableInAppCurrency;

// flag that marks if store has been loaded succesfully
BOOL storeLoaded;

@implementation Store

+ (void)setupWithStoreDictionary:(NSDictionary *)storeDictionary
{
    storeContent = storeDictionary;
}

+ (void)setupDefault
{
    if (!storeLoaded)
    {
        inGameStoreItems = [[NSMutableArray alloc] init];

        storeLoaded = TRUE;
        // create some demo store items
        
        CoinPurchaseStoreItem *item1 = [[CoinPurchaseStoreItem alloc] init];
        item1.title = @"40 Coins";
        item1.thumbnailFilename = @"missions_1.png";
        item1.detailDescription = @"Pocket Money!";
        item1.cost = 0.99f;
        item1.coinValue = 40;
        item1.productID = @"TestProductID";
        item1.inGameStoreImageFile = @"buy1.png";
        
        CoinPurchaseStoreItem *item2 = [[CoinPurchaseStoreItem alloc] init];
        item2.title = @"100 Coins";
        item2.thumbnailFilename = @"missions_1.png";
        item2.detailDescription = @"Starter Pack!";
        item2.cost = 1.99f;
        item2.coinValue = 100;
        item2.productID = @"TestProductID";
        item2.inGameStoreImageFile = @"buy2.png";
        
        CoinPurchaseStoreItem *item3 = [[CoinPurchaseStoreItem alloc] init];
        item3.title = @"500 Coins";
        item3.thumbnailFilename = @"missions_1.png";
        item3.detailDescription = @"Big Boy!";
        item3.cost = 3.99f;
        item3.coinValue = 500;
        item3.productID = @"TestProductID";
        item3.inGameStoreImageFile = @"buy3.png";
        
        CoinPurchaseStoreItem *item4 = [[CoinPurchaseStoreItem alloc] init];
        item4.title = @"1000 Coins";
        item4.thumbnailFilename = @"missions_1.png";
        item4.detailDescription = @"Pro!";
        item4.cost = 5.99f;
        item4.coinValue = 1000;
        item4.productID = @"TestProductID";
        item4.inGameStoreImageFile = @"buy3.png";
        
        CoinPurchaseStoreItem *item5 = [[CoinPurchaseStoreItem alloc] init];
        item5.title = @"1500 Coins";
        item5.thumbnailFilename = @"missions_1.png";
        item5.detailDescription = @"A huge bunch of coins!";
        item5.cost = 6.99f;
        item5.coinValue = 1500;
        item5.productID = @"TestProductID";
        item5.inGameStoreImageFile = @"buy3.png";
        
        CoinPurchaseStoreItem *item6 = [[CoinPurchaseStoreItem alloc] init];
        item6.title = @"2000 Coins";
        item6.thumbnailFilename = @"missions_1.png";
        item6.detailDescription = @"You are rich!";
        item6.cost = 7.49f;
        item6.coinValue = 2000;
        item6.productID = @"TestProductID";
        item6.inGameStoreImageFile = @"buy3.png";
        
        // these are the items presented in the in game store
        inGameStoreItems = [@[item1, item2, item3] mutableCopy];
        NSDictionary *setup = @{@"Coins": @[item1, item2,item3, item4, item5, item6]};
        
        [self setupWithStoreDictionary:setup];
        
        // load the amount of available In-App currency
        NSNumber *inAppCurrency = [MGWU objectForKey:KEY_IN_APP_CURRENCY];
        availableInAppCurrency = [inAppCurrency intValue];
    }
}

+ (NSArray *)inGameStoreStoreItems
{
    return inGameStoreItems;
}

+ (void)purchaseStoreItem:(StoreItem *)storeItem
{
    if ([storeItem isKindOfClass:[CoinPurchaseStoreItem class]])
    {
        [Store addInAppCurrency:[(CoinPurchaseStoreItem *) storeItem coinValue]];
    }
}

+ (BOOL)hasSufficientFundsForSkipAheadAction
{
    return (availableInAppCurrency >= 40);
}

+ (BOOL)purchaseSkipAheadAction
{
    if (availableInAppCurrency >= 40)
    {
        [self subtractInAppCurrency:40];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

+ (BOOL)hasSufficientFundsForGoOnAction
{
    return (availableInAppCurrency >= 100);
}

+ (BOOL)purchaseGoOnAction
{
    if (availableInAppCurrency >= 100)
    {
        [self subtractInAppCurrency:100];
        return TRUE;
    }
    else {
        return FALSE;
    }
}

+ (void)boughtProduct:(NSString *)response
{
    // TODO
    //NSLog(response);
}

+ (NSArray *)categories
{
    return [storeContent allKeys];
}

+ (NSArray *)storeItemsByCategory:(NSString *)category
{
    return [storeContent objectForKey:category];
}

+ (NSArray *)allStoreItems
{
    NSMutableArray *allItems = [NSMutableArray array];
    
    for (NSString *key in [storeContent allKeys])
    {
        [allItems addObjectsFromArray:[storeContent objectForKey:key]];
    }
    
    return allItems;
}

+ (int)availableAmountInAppCurrency
{
    return availableInAppCurrency;
}

+ (void)addInAppCurrency:(int)additionalCurrency
{
    availableInAppCurrency += additionalCurrency;
    
    // persist the new amount of In-App currency
    NSNumber *inAppCurrency = [NSNumber numberWithInt:availableInAppCurrency];
    [MGWU setObject:inAppCurrency forKey:KEY_IN_APP_CURRENCY];
}

+ (void)subtractInAppCurrency:(int)amountSubtraction
{
    availableInAppCurrency -= amountSubtraction;
    
    // persist the new amount of In-App currency
    NSNumber *inAppCurrency = [NSNumber numberWithInt:availableInAppCurrency];
    [MGWU setObject:inAppCurrency forKey:KEY_IN_APP_CURRENCY];
}

@end
