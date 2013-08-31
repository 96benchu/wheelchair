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
@interface StoreScreenScene :CCLayer
{
    CCNode *node;
    CCLabelTTF* upgraded1;
    CCLabelTTF* upgraded2;
    CCLabelTTF* coinCount;
}

-(void)upgrade;
-(void)upgrade2;
@end



 