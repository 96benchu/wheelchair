//
//  StoreScene.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "StoreScreenScene.h"
#import "StoreTableViewCell.h"
#import "StoreTableViewHeaderCell.h"
#import "Store.h"
#import "CCMenuNoSwallow.h"
#import "PopupProvider.h"
#import "CCControlButton.h"
#import "STYLES.h"
#import "StyleManager.h"
#import "GameplayLayer.h"

#define ROW_HEIGHT 39
#define ROW_HEIGHT_HEADER 20
#define SECTION_INDEX 1
#define TABLE_WIDTH 480

@implementation SWTableViewNodeCell
@synthesize node;

-(void)setNode:(CCNode *)s {
    if (node) {
        [self removeChild:node cleanup:NO];
    }
    s.anchorPoint = s.position = CGPointZero;
    node = s;
    [self addChild:node];
}
-(CCNode *)node {
    return node;
}
-(void)reset {
    //[super reset];
    if (node) {
        [self removeChild:node cleanup:NO];
    }
    node = nil;
}
@end

@interface StoreScreenScene()

// provides section header cells
- (SWTableViewCell *)sectionHeaderWithTitle:(NSString *)title;

// updates the display of available amount of money
- (void)updateCashDisplay;

@end

@implementation StoreScreenScene

@synthesize hasVariableCellSize = _hasVariableCellSize, tableContentSize = _tableContentSize;

- (id)init {
    self = [super init];
    
    if (self) {
        _hasVariableCellSize = TRUE;
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        
        [self setupWithStoreContent];
        
        float tableHeight=0;
        
        for (NSUInteger i = 0; i<[self numberOfCellsInTableView:nil]; i++)
        {
            CGSize size = [self tableView:nil cellSizeForIndex:i];
            tableHeight+=size.height;
        }
        
        // add a store background
        CCSprite *storeBackground = [CCSprite spriteWithFile:@"store_background.png"];
        storeBackground.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [self addChild:storeBackground z:-10];
        
        // add a store header
        CCSprite *storeHeader = [CCSprite spriteWithFile:@"store_header.png"];
        storeHeader.position = ccp(self.contentSize.width / 2, self.contentSize.height - (0.5 * storeHeader.contentSize.height));
        [self addChild:storeHeader];
        
        // add a store footer
        CCSprite *storeFooter = [CCSprite spriteWithFile:@"store_footer.png"];
        storeFooter.position = ccp(self.contentSize.width / 2, (0.5 * storeFooter.contentSize.height));
        [self addChild:storeFooter];
        
        // add a coin-symbol for the cash display
        CCSprite *storeCoinIcon = [CCSprite spriteWithFile:@"storecoin.png"];
        storeCoinIcon.position = ccp(40, self.contentSize.height - (storeHeader.contentSize.height / 2));
        [self addChild:storeCoinIcon];
        
        // add a label for available cash
        availableCashLabel = [CCLabelTTF labelWithString:@"CASH"
                                                fontName:DEFAULT_FONT
                                                fontSize:20];
        availableCashLabel.color = DEFAULT_FONT_COLOR;
        availableCashLabel.position = ccp(80, self.contentSize.height - 25);
        [self addChild:availableCashLabel];
        
        _tableContentSize=CGSizeMake(screenSize.width, tableHeight);

        float tableViewHeight = screenSize.height - storeHeader.contentSize.height - storeFooter.contentSize.height;
        storeTableView = [SWTableView viewWithDataSource:self size:CGSizeMake(TABLE_WIDTH, tableViewHeight)];

        float storeTableXPosition = (self.contentSize.width - TABLE_WIDTH) / 2;
        storeTableView.position = ccp(storeTableXPosition, storeFooter.contentSize.height);
        storeTableView.verticalFillOrder = SWTableViewFillTopDown;
        storeTableView.clipsToBounds = TRUE;
        storeTableView.bounces = TRUE;
        [self addChild:storeTableView];
        
        // add a resume button
        CCSprite *resumeButtonNormal = [CCSprite spriteWithFile:@"store_button_playbutton.png"];
        CCMenuItem *resumeMenuItem = [[CCMenuItemSprite alloc] initWithNormalSprite:resumeButtonNormal selectedSprite:nil disabledSprite:nil target:self selector:@selector(newGameButtonPressed)];
        
        CCMenu *menu = [CCMenu menuWithItems:resumeMenuItem, nil];
        [menu alignItemsHorizontally];
        menu.position = ccp(self.contentSize.width/2, 4 + resumeMenuItem.contentSize.height / 2);
        [self addChild:menu];
        
        [self updateCashDisplay];
    }
    
    return self;
}

- (void)setupWithStoreContent
{    
    cells = [NSMutableArray array];
    NSUInteger index = 0;
    
    NSArray *storeItemCategories = [Store categories];
    
    for (unsigned int j = 0; j < [storeItemCategories count]; j++)
    {
        NSString *storeCategory = [storeItemCategories objectAtIndex:j];
        // Add a section header for each store item category
        SWTableViewCell *sectionCell = [self sectionHeaderWithTitle:storeCategory];
        NSString *categoryName = storeCategory;
        sectionCell = [self sectionHeaderWithTitle:categoryName];
        sectionCell.idx = index;
        sectionCell.contentSize = CGSizeMake(TABLE_WIDTH, ROW_HEIGHT_HEADER);;
        sectionCell.size = sectionCell.contentSize;
        
        [cells addObject:sectionCell];
        // increase the current cell index
        index ++;
        
        // Add a item entry for each item in this category
        NSArray *itemsInCategory = [Store storeItemsByCategory:storeCategory];
        
        for (unsigned int i = 0; i < [itemsInCategory count]; i++)
        {            
            StoreTableViewCell *itemCell = [[StoreTableViewCell alloc] init];
            StoreItem *storeItem = [itemsInCategory objectAtIndex:i];
            [itemCell setupWithStoreItem:storeItem];
            itemCell.idx = index;
            itemCell.contentSize = CGSizeMake(TABLE_WIDTH, ROW_HEIGHT);
            itemCell.size = itemCell.contentSize;
            itemCell.delegate = self; 
            
            [cells addObject:itemCell];
            index++;
        }
    }
}

- (void)newGameButtonPressed
{
    CCScene *game = [GameplayLayer noMenuScene];
    [[CCDirector sharedDirector] replaceScene:game];
}

- (void)updateCashDisplay
{
    availableCashLabel.string = [NSString stringWithFormat:@"%d",[Store availableAmountInAppCurrency]];
}

#pragma mark - StoreDisplayNeedsUpdateDelegate

- (void)storeDisplayNeedsUpdate
{
    [self updateCashDisplay];
}

#pragma mark - TableViewDelegate

-(SWTableViewCell*)tableView:(SWTableView *)table cellAtIndex:(NSUInteger)idx;
{
    SWTableViewNodeCell *cell = (SWTableViewNodeCell *) [table dequeueCell];
    
    if (cell)
    {
        [cell reset];
        [cell removeAllChildrenWithCleanup:YES];
    }
    else
    {
        cell = [[SWTableViewNodeCell alloc] init];
    }

    
    // initialize cell, since none could be dequed
    SWTableViewCell *templateCell = [cells objectAtIndex:idx];
    
    if ([templateCell isKindOfClass:[StoreTableViewCell class]])
    {
        cell.node = [StoreTableViewCell cellWithStoreTableViewCell:(StoreTableViewCell *)templateCell];
    } else if ([templateCell isKindOfClass:[StoreTableViewHeaderCell class]])
    {
        cell.node = [StoreTableViewHeaderCell cellWithStoreTableViewHeaderCell:(StoreTableViewHeaderCell *) templateCell];
    }
    
    return cell;
}

-(CGSize)tableView:(SWTableView *)table cellSizeForIndex:(NSUInteger)index
{
    CGSize cellSize = [[cells objectAtIndex:index] contentSize];
        
    return cellSize;
}

-(float)tableView:(SWTableView *)table heightFromCellIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    float height = 0;
    for (NSUInteger i = index1; i<index2; i++)
    {
        height += ((CGSize)[self tableView:table cellSizeForIndex:i]).height;
    }
    return height;
}

-(float)tableView:(SWTableView *)table widthFromCellIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2
{
    return self.contentSize.width;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table
{
    return [cells count];
}

- (SWTableViewCell *)sectionHeaderWithTitle:(NSString *)title
{
    StoreTableViewHeaderCell *cell = [[StoreTableViewHeaderCell alloc] init];
    [cell setupWithTitle:title];
    
    return cell;
}

@end
