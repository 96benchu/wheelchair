//
//  StoreItem.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/23/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import <Foundation/Foundation.h>

@interface StoreItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detailDescription;
@property (nonatomic, strong) NSString *thumbnailFilename;

// this property is optional. It is only required if the store item shall be presentable in the In-Game-Store
@property (nonatomic, strong) NSString *inGameStoreImageFile;

// stores the cost for this item
@property (nonatomic, assign) float cost;

@end
