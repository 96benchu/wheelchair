//
//  TabNode.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/15/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCNode.h"

@protocol TabNodeProtocol <NSObject>

@optional

// this method is called, one one of the tabs, when the TabNode is about to present it
- (void)tabWillAppear;
// this method is called, one one of the tabs, when the TabNode is about to hide it
- (void)tabWillDisappear;

@end

@interface TabNode : CCNode
{
    NSArray *tabTitles;
    NSMutableArray *tabButtons;
}

// expects an array of CCNodes and an array of Strings
-(id)initWithTabs:(NSArray *)tabs tabTitles:(NSArray *)tabTitles;

// an array of CCNodes which are the availabe tabs of this tabView
@property (nonatomic, strong) NSArray *tabs;

@end
