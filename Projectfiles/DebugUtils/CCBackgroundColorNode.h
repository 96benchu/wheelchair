//
//  CCNode+CCNode_BackgroundColor.h
//  _MGWU-SideScroller-Template_
//
//  Created by Benjamin Encz on 5/22/13.
//  Copyright (c) 2013 MakeGamesWithUs Inc. Free to use for all purposes.
//

#import "CCBackgroundColorNode.h"

/**
 This CCNode subclass adds a background color as property to the node.
 It is initialized with a random color (usefull for debuging view sizes).
 
 The z-Layer on which the background is drawn can be changed.
 **/

@interface CCBackgroundColorNode : CCNode

@property (nonatomic, assign) ccColor4B backgroundColor;
@property (nonatomic, assign) int backgroundColorZLayer;

@end
