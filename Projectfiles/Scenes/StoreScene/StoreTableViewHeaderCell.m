//
//  StoreTableViewHeaderCell.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/24/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "StoreTableViewHeaderCell.h"
#import "CCScale9Sprite.h"
#import "STYLES.h"

@implementation StoreTableViewHeaderCell

@synthesize title = _title;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        storeItemLabel = [CCLabelTTF labelWithString:@""
                                            fontName:DEFAULT_FONT
                                            fontSize:12];
        storeItemLabel.color = WHITE_FONT_COLOR;
        storeItemLabel.anchorPoint = ccp(0, 0.5);
        [self addChild:storeItemLabel];
        
        backgroundSprite =  [[CCSprite alloc] initWithFile:@"store_categorybar.png"];
        [self addChild:backgroundSprite z:-1];
    }
    
    return self;
}

- (void)setupWithTitle:(NSString *)title
{
    _title = title;
    storeItemLabel.string = title;
}

+ (StoreTableViewHeaderCell *)cellWithStoreTableViewHeaderCell:(StoreTableViewHeaderCell *)cell
{
    StoreTableViewHeaderCell *storeTableViewHeaderCell = [[StoreTableViewHeaderCell alloc] init];
    [storeTableViewHeaderCell setupWithTitle:cell.title];
    storeTableViewHeaderCell.idx = cell.idx;
    storeTableViewHeaderCell.contentSize = cell.contentSize;
    storeTableViewHeaderCell.size = cell.size;
    
    return storeTableViewHeaderCell;
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    storeItemLabel.position = ccp(10, self.contentSize.height / 2);
    
    backgroundSprite.contentSize = self.contentSize;
    backgroundSprite.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
}

@end
