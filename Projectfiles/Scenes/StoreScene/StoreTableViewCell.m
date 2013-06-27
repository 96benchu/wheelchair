//
//  LeaderBoardTableViewCell.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "STYLES.h"
#import "StoreTableViewCell.h"
#import "CCScale9Sprite.h"
#import "CCSprite+scaleSpriteToFitContentSize.h"
#import "StyleManager.h"
#import "STYLES.h"
#import "PopupProvider.h"
#import "Store.h"
#import "VirtualCurrencyStoreItem.h"
#import "CoinPurchaseStoreItem.h"

@interface StoreTableViewCell()

- (void)purchaseButtonSelected;

@end

@implementation StoreTableViewCell


@synthesize storeItem = _storeItem;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // add title label
        storeItemLabel = [CCLabelTTF labelWithString:@""
                                           fontName:DEFAULT_FONT
                                           fontSize:16];
        storeItemLabel.color = DEFAULT_FONT_COLOR;
        storeItemLabel.anchorPoint = ccp(0, 0.5);
        [self addChild:storeItemLabel];
        
        
        // add description label
        storeItemDetailDescriptionLabel = [CCLabelTTF labelWithString:@""
                                                             fontName:DEFAULT_FONT
                                                             fontSize:12];
        storeItemDetailDescriptionLabel.color = DEFAULT_FONT_COLOR;
        storeItemDetailDescriptionLabel.anchorPoint = ccp(0, 0.5);
        storeItemDetailDescriptionLabel.contentSize = CGSizeMake(150 ,storeItemDetailDescriptionLabel.contentSize.height);
        [self addChild:storeItemDetailDescriptionLabel];

        // add cost label
        costLabel = [CCLabelTTF labelWithString:@""
                                       fontName:DEFAULT_FONT
                                       fontSize:16];
        costLabel.color = DEFAULT_FONT_COLOR;
        costLabel.anchorPoint = ccp(0, 0.5);
        costLabel.contentSize = CGSizeMake(150 ,costLabel.contentSize.height);
        [self addChild:costLabel];
        
        backgroundSprite = [[CCSprite alloc] initWithFile:@"storeCellBackground.png"];
        [self addChild:backgroundSprite z:-1];
        
        purchaseButton = [[CCControlButton alloc] initWithBackgroundSprite:[StyleManager scaleSpriteWhiteBackgroundSolidBlackBorder]];
        [purchaseButton setTitleTTF:DEFAULT_FONT forState:CCControlStateNormal];
        [purchaseButton setTitleTTFSize:10 forState:CCControlStateNormal];
        [purchaseButton setTitleColor:DEFAULT_FONT_COLOR forState:CCControlStateNormal];
        [purchaseButton setTitle:@"BUY" forState:CCControlStateNormal];
        [purchaseButton addTarget:self action:@selector(purchaseButtonSelected) forControlEvents:CCControlStateNormal];
        purchaseButton.preferredSize = CGSizeMake(44, 24);
        purchaseButton.touchPriority = -1;
        
        [self addChild:purchaseButton];
    }
    
    return self;
}

+ (StoreTableViewCell *)cellWithStoreTableViewCell:(StoreTableViewCell *)cell
{
    StoreTableViewCell *storeTableViewCell = [[StoreTableViewCell alloc] init];
    [storeTableViewCell setupWithStoreItem:cell.storeItem];
    storeTableViewCell.idx = cell.idx;
    storeTableViewCell.contentSize = cell.contentSize;
    storeTableViewCell.size = cell.size;
    storeTableViewCell.delegate = cell.delegate;
    
    return storeTableViewCell;
}

- (void)setupWithStoreItem:(StoreItem *)storeItem
{
    _storeItem = storeItem;
    storeItemLabel.string = storeItem.title;
    
    if (self.storeItem.thumbnailFilename)
    {
        storeItemThumbnail = [CCSprite spriteWithFile:self.storeItem.thumbnailFilename];
        storeItemThumbnail.anchorPoint = ccp(0, 0);
        [self addChild:storeItemThumbnail];
    }
    
    if ([self.storeItem isKindOfClass:[VirtualCurrencyStoreItem class]])
    {
        coinIcon = [CCSprite spriteWithFile:@"coin.png"];
        [self addChild:coinIcon];
        costLabel.string = [NSString stringWithFormat:@"%.2f", self.storeItem.cost];
    }
    else
    {
        costLabel.string = [NSString stringWithFormat:@"$ %.2f", self.storeItem.cost];
    }
    
    storeItemDetailDescriptionLabel.string = storeItem.detailDescription;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    // size background sprite
    backgroundSprite.contentSize = self.contentSize;
    backgroundSprite.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
    
    if (self.storeItem.thumbnailFilename)
    {
        // position thumbnail
        storeItemThumbnail.contentSize = CGSizeMake(self.contentSize.height * 0.8, self.contentSize.height * 0.8);
        storeItemThumbnail.position = ccp(5, storeItemThumbnail.contentSize.height * 0.1);
        [storeItemThumbnail scaleSpriteToFitContentSize];
        
        // position label relative to thumbnail
        storeItemLabel.position = ccp(storeItemThumbnail.position.x + storeItemThumbnail.contentSize.width + 10 , self.contentSize.height / 2);
    } else
    {
        // position label
        storeItemLabel.position = ccp(10 , self.contentSize.height / 2);
    }
    
    // position description label
    storeItemDetailDescriptionLabel.position = ccp(150 , self.contentSize.height / 2);
    
    // position coin icon
    coinIcon.position = ccp(self.contentSize.width - 150, self.contentSize.height / 2);
    
    // position cost label
    if ([self.storeItem isKindOfClass:[VirtualCurrencyStoreItem class]])
    {
        costLabel.position = ccp(coinIcon.position.x + coinIcon.contentSize.width, self.contentSize.height / 2);
    } else
    {
        costLabel.position = ccp(self.contentSize.width - 150, self.contentSize.height / 2);
    }
    
    purchaseButton.anchorPoint = ccp(0, 0.5);
    purchaseButton.position = ccp(self.contentSize.width - 50, self.contentSize.height / 2);
}

- (void)purchaseButtonSelected
{
    if ([self.storeItem isKindOfClass:[VirtualCurrencyStoreItem class]])
    {
        // for virtual products display the popup
        // TODO: implement purchasing of virtual products
        popUp = [PopupProvider presentPopUpWithContentString:@"You successfully bought item" target:self selector:@selector(popUpButtonClicked:) buttonTitles:@[@"OK", @"Cancel"]];
        CCLOG(@"Purchasing %@", self.storeItem.title);
    } else if ([self.storeItem isKindOfClass:[CoinPurchaseStoreItem class]])
    {
        CoinPurchaseStoreItem *storeItem = (CoinPurchaseStoreItem *) self.storeItem;
        [MGWU testBuyProduct:storeItem.productID withCallback:@selector(boughtProduct:) onTarget:self];
    }
}

- (void)boughtProduct:(NSString *)response
{
    if (response != nil)
    {
        // product has been purchased succesfully
        if ([self.storeItem isKindOfClass:[CoinPurchaseStoreItem class]])
        {
            CoinPurchaseStoreItem *storeItem = (CoinPurchaseStoreItem *) self.storeItem;
            [Store purchaseStoreItem:storeItem];
            [self.delegate storeDisplayNeedsUpdate];
            
            NSString *popUpMessage = [NSString stringWithFormat:@"You successfully bought \n%@", storeItem.title];
            if (popUp)
            {
                // avoid multiple popups for the same cell overlaying
                [popUp dismiss];
            }
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
    } else if (sender.tag == 1)
    {
        // Cancel button selected
        [popUp dismiss];
    }
}

@end
