//
//  TabNode.m
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "TabNode.h"
#import "STYLES.h"
#import "StyleManager.h"
#import "CCScale9Sprite.h"

#define TAB_BUTTON_HEIGHT 26

@interface TabNode()

- (void)tabSelected:(CCNode *)selectedTab byTabButton:(CCControlButton *)tabButton;

@end

@implementation TabNode

-(id)initWithTabs:(NSArray *)tabs tabTitles:(NSArray *)tTitles
{
    self = [super init];
    
    if (self) {
        self.tabs = tabs;
        tabTitles = tTitles;
        tabButtons = [NSMutableArray array];
        NSAssert([self.tabs count] == [tabTitles count], @"Amount of tabs and tab titles need to match");
    }
    
    return self;
}

- (void)onExit
{
    [super onExit];
    
    [self removeAllChildren];
}

- (void)onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    
    int xPos = 0;
    
    for (unsigned int i = 0; i < [self.tabs count]; i++)
    {
        CCNode *tab = [self.tabs objectAtIndex:i];
        NSString *tabTitle = [tabTitles objectAtIndex:i];
        // add a tab bar button for each tab
        CCControlButton *tabButton = [StyleManager defaultRecapSceneTabButtonWithTitle:tabTitle];
        tabButton.anchorPoint = ccp(0,1);
        tabButton.position = ccp(xPos, self.contentSize.height);

        [tabButton setBlock:^(id sender, CCControlEvent event) {
            [self tabSelected:tab byTabButton:sender];
        } forControlEvents:CCControlEventTouchUpInside];
        
        xPos += tabButton.contentSize.width + 2;
        
        [self addChild:tabButton];
        [tabButtons addObject:tabButton];
        
        tab.anchorPoint = ccp(0,1);

        tab.position = ccp(0, self.contentSize.height - TAB_BUTTON_HEIGHT);
        [self addChild:tab];
    }
    
    // initially select the first tab
    CCNode *firstTab = [self.tabs objectAtIndex:0];
    CCControlButton *firstButton = [tabButtons objectAtIndex:0];
    [self tabSelected:firstTab byTabButton:firstButton];
}

- (void)tabSelected:(CCNode *)selectedTab byTabButton:(CCControlButton *)selectedTabButton
{
    // this loops makes the selected tab visible and all other tabs unvisible
    for (CCNode *tab in self.tabs)
    {
        if ([selectedTab isEqual:tab])
        {
            tab.visible = TRUE;
            if ([tab respondsToSelector:@selector(tabWillAppear)])
            {
                /* since we know, that the tab responds to tabWillAppear, we can cast it into a class implementing the TabNodeProtocol,
                 this allows us to safely call "tabWillAppear" */
                [(id<TabNodeProtocol>) tab tabWillAppear];
            }
        } else
        {
            tab.visible = FALSE;
            if ([tab respondsToSelector:@selector(tabWillDisappear)])
            {
                /* since we know, that the tab responds to tabWillAppear, we can cast it into a class implementing the TabNodeProtocol,
                 this allows us to safely call "tabWillDisappear" */
                [(id<TabNodeProtocol>) tab tabWillDisappear];
            }
        }
    }
    
    // this loops marks the selected tab button as selected
    for (CCControlButton *tabButton in tabButtons)
    {
        if ([tabButton isEqual:selectedTabButton])
        {
            tabButton.selected = TRUE;
        }
        else
        {
            tabButton.selected = FALSE;
        }
    }
}


@end
